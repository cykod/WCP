

class DeploymentBlueprint
  include SimplyStored::Couch

  property :name

  validates_presence_of :name

  has_many :deployment_parameters
  has_many :deployment_steps

  def initialize_step(step_data)
    if !step_data.initialized?
      self.steps[step_data.step].initialize_step_data(step_data)
    end
    step_data
  end

 def add_step(name,step_class_name)
    
    self.reload
    cls = step_class_name.constantize


    next_position = self.steps[-1] ? self.steps[-1].position + 1 : 0
    substeps = cls.step_info_details[:substeps]
    (0..substeps-1).each do |substep|
      DeploymentStep.create(:name => name,
                            :position => next_position,
                            :substep => substep,
                            :deployment_blueprint_id => self.id,
                            :step_class_name => step_class_name,
                            :step_options_class_name => cls.step_info_details[:options])

      next_position += 1
    end
    self.reload
  end

 def finished?(step_number)
   step_number >= self.steps.length
 end
  
  def step_finished?(step_data)
    self.steps[step_data.step].finished?(step_data)
  end

  def execute_step!(step_data)
    if step_data.step > self.steps.length
      return false
    else
      self.steps[step_data.step].execute!(step_data)
    end
  end

  def machine_failed!(step_data,machine)
    self.steps[step_data.step].machine_failed!(step_data,machine)
  end

  def machine_activated!(step_data,machine)
    self.steps[step_data.step].machine_activated!(step_data,machine)
  end

  def steps
    self.deployment_steps.sort { |a,b| a.position <=> b.position }
  end
  
end
