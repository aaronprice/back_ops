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

    scope :globals_contains, ->(hash) {
      where('globals @> ?', hash.to_json)
    }

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    self.table_name = 'back_ops_operations'

    # == Instance Methods =====================================================

    def first_action
      self.actions.
        where(back_ops_actions: { branch: 'main' }).
        order(order: :asc).
        limit(1).
        first
    end

    def get(field)
      globals[field.to_s]
    end

    def set(field, value)
      globals[field.to_s] = value
      save!
    end

  end
end