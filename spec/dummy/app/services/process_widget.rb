class ProcessWidget
  def self.call(params)
    BackOps::Worker.perform_async(params, [
      Actions::SetToInProgress,
      Actions::SetToProcessed
    ])
  end
end