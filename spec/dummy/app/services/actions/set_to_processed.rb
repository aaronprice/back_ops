module Actions
  class SetToProcessed
    def self.call(action)
      widget = Widget.find(action.get('widget_id'))
      widget.state = 'processed'
      widget.save!
    end
  end
end