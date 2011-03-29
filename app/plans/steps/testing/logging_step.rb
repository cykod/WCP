
class Steps::Testing::LoggingStep < Steps::Base

  step_info "(Z) Step that logs", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    self.deployment.log("Logging this is active in substep #{step.substep}")
  end


  def finished?(step)
    self.deployment.log("Logging this is finished in substep #{step.substep}")
    true
  end

end


