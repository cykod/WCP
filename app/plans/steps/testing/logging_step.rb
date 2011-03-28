
class Steps::Testing::LoggingStep < Steps::Base

  step_info "Step that logs", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    self.deployment.log("This is substep #{step.substep}")
  end


  def finished?(step)
    true
  end

end


