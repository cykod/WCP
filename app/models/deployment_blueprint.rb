

class DeploymentBlueprint
  include SimplyStored::Couch

  property :name

  has_many :deployment_parameters
  has_many :deployment_steps

  def check_step(step_data)
    if !step_data.initialized?
      self.steps[step_data.step].initialize_step_data(step_data)
    end
    step_data
  end
  
  def step_finished?(step_data)
    self.steps[step_data.step].finished?(check_step(step_data))
  end

  def execute_step!(step_data)
    if step_data.step > self.steps.length
      return false
    else
      self.steps[step_data.step].execute!(check_step(step_data))
    end
  end

  def machine_failed!(step_data,machine)
    self.steps[step_data.step].machine_failed!(check_step(step_data),machine)
  end

  def machine_activated!(step_data,machine)
    self.steps[step_data.step].machine_activated!(check_step(step_data),machine)
  end

  def steps
    self.deployment_steps.sort { |a,b| a.position <=> b.position }
  end
  
end
