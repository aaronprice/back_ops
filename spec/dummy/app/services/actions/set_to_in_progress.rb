module Actions
  class SetToInProgress
    def self.call(operation)
      widget = Widget.find(operation.context['widget_id'])
      widget.state = 'in_progress'
      widget.save!
    end
  end
end