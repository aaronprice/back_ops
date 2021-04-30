module BackOps
  class Action < ActiveRecord::Base

    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    # == Relationships ========================================================

    belongs_to :operation, class_name: 'BackOps::Operation'

    # == Validations ==========================================================

    # == Scopes ===============================================================

    scope :locals_contains, ->(hash) {
      where('locals @> ?', hash.to_json)
    }

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    self.table_name = 'back_ops_actions'

    def self.after(action)
      next_on_branch = BackOps::Action.where(operation: action.operation, branch: action.branch).
                      where('back_ops_actions.order > ?', action.order).
                      order(order: :asc).
                      limit(1).
                      first

      return next_on_branch if next_on_branch.present?

      BackOps::Action.where({
          operation: action.operation,
          branch: 'main',
          completed_at: nil
        }).
        limit(1).
        first
    end

    # == Instance Methods =====================================================

    def premature?
      perform_at.present? && perform_at > Time.zone.now
    end

    def get(field)
      self.operation.get(field)
    end

    def set(field, value)
      self.operation.set(field, value)
    end

    def get_local(field)
      self.locals[field]
    end

    def set_local(field, value)
      self.locals[field] = value
      self.save!
    end

    def jump_to(pointer)
      # :branch
      # { branch: Action }
      # { branch: [Action, locals] }
      if pointer.is_a?(Symbol)
        self.operation.next_action = self.operation.actions.where(branch: pointer).order(order: :asc).limit(1).first
      elsif pointer.is_a?(Hash)
        branch, action = pointer.first
        name, locals = [*action]
        locals ||= {}
        locals.deep_stringify_keys!

        locals_query = locals.present? ? ['locals @> ?', locals] : {}

        self.operation.next_action = self.operation.actions.
                                      where(branch: branch).
                                      where(locals_query).
                                      order(order: :asc).
                                      limit(1).
                                      first
      else
        raise ArgumentError, 'jump_to only accepts as Symbol or a Hash'
      end
      self.operation.save!
    end

    def mark_errored(e)
      self.error_message = e.message
      self.stack_trace = e.backtrace
      self.errored_at = Time.zone.now

      self.attempts_count += 1
      self.save!
    end

    def mark_completed
      self.errored_at = nil
      self.error_message = nil
      self.stack_trace = nil

      self.completed_at = Time.zone.now
      self.attempts_count += 1
      self.save!
    end
  end
end