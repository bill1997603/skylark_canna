class ProblemProcessorJob < ApplicationJob
  queue_as :default

  def perform(filename)
    Problem.import filename
    File.delete filename
  end
end
