module BackOps
  class Operation < ActiveRecord::Base

    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    # == Relationships ========================================================

    belongs_to :next_action, class_name: 'BackOps::Action'

    has_many :actions, class_name: 'BackOps::Action'

    # == Validations ==========================================================

    # == Scopes ===============================================================

    scope :context_contains, ->(hash) {
      where('context @> ?', hash.to_json)
    }

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    self.table_name = 'back_ops_operations'

    # == Instance Methods =====================================================

    def first_action
      self.actions.
        where(back_ops_actions: { path: 'main' }).
        order(order: :asc).
        limit(1).
        first
    end

    def get(field)
      context[field.to_s]
    end

    def set(field, value)
      context[field.to_s] = value
      save!
    end

  end
end