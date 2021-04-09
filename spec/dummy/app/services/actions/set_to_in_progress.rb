module Actions
  class SetToInProgress
    def self.call(operation)
      widget = Widget.find(operation.get(:widget_id))
      widget.state = 'in_progress'
      widget.save!
    end
  end
end