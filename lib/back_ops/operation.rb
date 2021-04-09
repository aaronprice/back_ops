module BackOps
  class Operation < ActiveRecord::Base

    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    # == Relationships ========================================================

    has_many :actions, class_name: 'BackOps::Action'

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    self.table_name = 'back_ops_operations'

    # == Instance Methods =====================================================

    def get(field)
      context[field.to_s]
    end

    def set(field, value)
      context[field.to_s] = value
      save!
    end
  end
end