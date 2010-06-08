

class DeploymentStep
  include SimplyStored::Couch

  belongs_to :deployment_blueprint
  property :position, :type => Fixnum
  property :name
  property :step_class_name
  property :step_options_class_name

  def initialize_step_data(step_data)
   step_data.options_class_name = self.step_options_class_name 
   step_data.initialized = true
   step_data.save
  end

  def step_class(deployment)
    @step_class ||= self.step_class_name.constantize.new(deployment,deployment_blueprint)
  end

  def finished?(step_data)
    returning(self.step_class(step_data.deployment).finished?(step_data)) { step_data.save }
  end

  def execute!(step_data)
    returning(self.step_class(step_data.deployment).execute!(step_data)) { step_data.save }
  end

  def machine_failed!(step_data)
    returning(self.step_class(step_data.deployment).machine_failed!(step_data,machine)) { step_data.save }
  end

  def machine_activated!(step_data,machine)
    returning(self.step_class(step_data.deployment).machine_activated!(step_data,machine)) { |step_data.save }
  end


end
