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

    def self.setup_operation_and_actions(context, actions)
      raise ArgumentError, 'Cannot process empty actions' if actions.blank?
      context.deep_stringify_keys!

      operation = BackOps::Operation.create_or_find_by({
        params_hash: Digest::MD5.hexdigest("#{context}|#{actions}"),
        name: ancestors[1]
      })
      operation.context.merge!(context)
      operation.save!
      
      actions.each_with_index do |action, index|
        BackOps::Action.create_or_find_by({
          operation: operation,
          name: action,
          order: index
        })
      end

      operation
    end

    # == Instance Methods =====================================================

    def perform(operation_id)
      operation = BackOps::Operation.find(operation_id)
      process(operation)
    end

    private

    def process(operation)
      action_items = BackOps::Action.where({
        operation: operation,
        completed_at: nil
      }).order(order: :asc)

      return true if action_items.blank?

      active_item = action_items[0]
      next_item = action_items[1]

      if active_item.errored_at.present?
        active_item.errored_at = nil
        active_item.error_message = nil
        active_item.stack_trace = nil
        active_item.save!
      end
      
      begin
        active_item.name.constantize.call(operation)

        active_item.completed_at = Time.zone.now
        active_item.attempts_count += 1
        active_item.save!

        if next_item.present?
          Sidekiq::Client.push('class' => self.class.name, 'args' => [operation.id])
        else
          operation.completed_at = active_item.completed_at
          operation.save!
        end
      rescue => e
        active_item.error_message = e.message
        active_item.stack_trace = e.backtrace
        active_item.errored_at = Time.zone.now
        active_item.attempts_count += 1
        active_item.save!

        raise
      end
    end
  end
end