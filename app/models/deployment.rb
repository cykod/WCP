
class Deployment
  include SimplyStored::Couch

  belongs_to :company
  belongs_to :cloud
  belongs_to :deployment_blueprint

  property :active_step, :type => Fixnum, :default => -1
  property :completed_step, :type => Fixnum, :default => -1

  property :deployment_options, :type => Hash, :default => {}
  property :data, :type => Hash, :default => {}
  property :timeout_date, :type => Time
  property :status, :default => 'created'

  has_many :machines
  has_many :deployment_step_data

  def add_machine(roles,blueprint,options={})
    self.machines.create(
        { 
          :roles => roles, :machine_blueprint => blueprint, :company => self.company,
          :cloud => cloud
        }.merge(:options)
    )
  end

  def execute!
    self.execute_step!(0)
    DeploymentMonitor.run_monitor!(self,self.active_step)
  end


  def step_finished?(step)
    step < active_step || self.deployment_blueprint.step_finished?(step_data(step))
  end


  def step_data(step)
     DeploymentStepDatum.find_by_deployment_id_and_step(self.id,step) ||
      self.deployment_step_data.create(:step => step)
  end


  def execute_step!(step)
    self.completed_step = step -1
    self.active_step = step
    if self.save
      if !self.deployment_blueprint.execute_step(step_data(self.active_step))
        self.status ='deployed'
        self.save
        return false
      end
    end
    true
  end


  def teardown!
    # Teardown the entire deployment
  end
  
  def machine_failed!(machine)
    self.deployment_blueprint.machine_failed!(step_data(self.active_step),machine)
  end

  def machine_activated!(machine)
    self.deployment_blueprint.machine_activated!(step_data(self.active_step),machine)
  end

end
