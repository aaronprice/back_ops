module BackOps
  class Worker

    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    include Sidekiq::Worker

    # == Aliases ==============================================================

    # == Class Methods ========================================================

    def self.perform_async(context, actions)
      operation = setup_operation_and_actions(context, actions)
      super(operation.id)
    end

    def self.perform_in(interval, context, actions)
      operation = setup_operation_and_actions(context, actions)
      super(interval, operation.id)
    end

    def self.perform_at(interval, context, action)
      perform_in(interval, context, action)
    end

    def self.setup_operation_and_actions(context, paths)
      raise ArgumentError, 'Cannot process empty actions' if paths.blank?

      context ||= {}
      context.deep_stringify_keys!

      operation = BackOps::Operation.create_or_find_by({
        params_hash: Digest::MD5.hexdigest("#{context}|#{paths}"),
        name: ancestors[1]
      })
      operation.context.merge!(context)
      operation.save!

      counter = 0

      paths.each do |path, actions|
        actions.each do |action_with_options|
          action_name, options = [*action_with_options]

          options = {
            'locals' => {},
            'perform_at' => nil
          }.merge(options.try(:deep_stringify_keys) || {})

          action = BackOps::Action.create_or_find_by({
            operation: operation,
            path: path,
            name: action_name,
            locals: options['locals'],
            perform_at: options['perform_at'],
            order: counter
          })

          counter += 1
        end
      end

      operation.next_action = operation.first_action
      operation.save!

      operation
    end

    # == Instance Methods =====================================================

    def perform(operation_id)
      operation = BackOps::Operation.find(operation_id)
      process(operation)
    end

    private

    def process(operation)
      action = operation.next_action
      return true if action.blank?
      return process_next(operation, at: action.perform_at.to_f) if action.premature?

      begin
        action.name.constantize.call(action)
        action.mark_completed

        operation.next_action = BackOps::Action.after(action)
        operation.save!

        if operation.next_action.present?
          process_next(operation)
        else
          operation.completed_at = action.completed_at
          operation.save!
        end

      rescue => e
        action.mark_errored(e)
        raise
      end
    end

    def process_next(operation, options = {})
      options.deep_stringify_keys!

      Sidekiq::Client.push({
        'class' => self.class.name,
        'args' => [operation.id]
      }.merge(options))

      true
    end
  end
end