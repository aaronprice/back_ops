module Actions
  class SetToPathOne
    def self.call(action)
      widget = Widget.find(action.get(:widget_id))
      widget.state = 'path_1'
      widget.save!

      action.jump_to(main: Actions::SetToProcessed)
    end
  end
end