class ProcessWidget
  def self.call(params)
    actions = {
      main: [
        Actions::SetToInProgress,
        Actions::SetToProcessed
      ],
      branch_1: [
        Actions::SetToBranchOne
      ]
    }

    BackOps::Worker.perform_async(params, actions)
  end
end