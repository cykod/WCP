class Steps::Testing::WriteConfigStep < Steps::Base

  step_info "(Z) Step that writes config", :substeps => 3

  class Options < HashModel
    attributes :dummy_config => nil

  end

  def execute!(step)
    step.config.dummy_config = "We're at substep: #{step.substep}"
  end


  def finished?(step)
    step.config.dummy_config == "We're at substep: #{step.substep}"
  end

end


