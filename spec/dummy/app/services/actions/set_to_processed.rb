module Actions
  class SetToProcessed
    def self.call(operation)
      widget = Widget.find(operation.context['widget_id'])
      widget.state = 'processed'
      widget.save!
    end
  end
end