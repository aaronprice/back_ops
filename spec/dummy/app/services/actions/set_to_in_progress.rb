module Actions
  class SetToInProgress
    def self.call(action)
      widget = Widget.find(action.get(:widget_id))
      widget.state = 'in_progress'
      widget.save!

      action.jump_to(:branch_1)
    end
  end
end