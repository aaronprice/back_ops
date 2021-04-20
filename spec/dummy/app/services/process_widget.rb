class ProcessWidget
  def self.call(params)
    actions = {
      main: [
        Actions::SetToInProgress,
        Actions::SetToProcessed
      ],
      path_1: [
        Actions::SetToPathOne
      ]
    }

    BackOps::Worker.perform_async(params, actions)
  end
end