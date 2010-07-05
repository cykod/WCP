
class Deployment < BaseModel
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
  has_many :deployment_step_data, :dependent => :destroy
  has_many :deployment_monitors, :dependent => :destroy

  def add_machine(roles,blueprint,options={})
    Machine.create(
        { 
          :step => self.active_step,
          :deployment => self,
          :roles => roles, 
          :machine_blueprint => blueprint, 
          :company => self.company,
          :cloud => cloud
        }.merge(options)
    )
  end

  def parameter(name)
    self.deployment_options[name.to_sym]
  end

  def execute!
    self.status ='deploying'
    self.execute_step!(0)
    DeploymentMonitor.run_monitor!(self,self.active_step)
  end

  def finished?
    self.deployment_blueprint.finished?(active_step)
  end


  def step_finished?(step_number)
    step_number < active_step || self.deployment_blueprint.step_finished?(step_data(step_number))
  end


  def step_data(step_number)
     step = DeploymentStepDatum.find_by_deployment_id_and_step(self.id,step_number) 
     unless step
       step = DeploymentStepDatum.new(:deployment => self,:step => step_number)
       self.deployment_blueprint.initialize_step(step)
     end
     step
  end

  def finish!
    self.status = 'deployed'
    self.cloud.deployment_finished!
    self.save
  end

  def execute_step!(step_number)
    self.completed_step = step_number -1
    self.active_step = step_number
    if self.save
      if self.finished?
        self.finish!
        return false
      else
        self.deployment_blueprint.execute_step!(step_data(self.active_step))
      end
    end
    true
  end


  def teardown!
    # Teardown the entire deployment
  end
  
  def machine_failed!(machine)
    self.deployment_blueprint.machine_failed!(step_data(machine.step),machine)
  end

  def machine_activated!(machine)
    self.deployment_blueprint.machine_activated!(step_data(machine.step),machine)
  end

end
