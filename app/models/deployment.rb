
class Deployment < BaseModel
  include SimplyStored::Couch

  belongs_to :company
  belongs_to :cloud
  belongs_to :blueprint

  attr_accessor :create_execute

  property :active_step, :type => Fixnum, :default => -1
  property :completed_step, :type => Fixnum, :default => -1

  property :deployment_options_data, :type => Hash, :default => {}
  property :data, :type => Hash, :default => {}
  property :timeout_date, :type => Time
  property :status, :default => 'created'
  property :failure_description 

  has_many :machines
  has_many :deployment_step_data, :dependent => :destroy
  has_many :deployment_monitors, :dependent => :destroy

  validates_presence_of :blueprint
  validates_presence_of :cloud

  has_options :status, [['Deploying','deploying'],['Deployed','deployed'],['Created','created'],['Failed','failed']]

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

  def name
    begin
      "#{self.blueprint.name} - #{self.cloud.name}"
    rescue 
      "Invalid Deployment"
    end
  end

  def blueprint_options
    self.blueprint.blueprint_options
  end

  def deployment_options=(val)
    self.deployment_options_data = self.blueprint.options(val).to_hash
  end

  def deployment_options
    self.blueprint.options(self.deployment_options_data)
  end

  def parameters
    self.blueprint.parameters
  end

  def parameter(name)
    self.deployment_options_data[name.to_sym]
  end

  def execute!
    self.status ='deploying'
    self.execute_step!(0)
    DeploymentMonitor.run_monitor!(self,self.active_step)
  end

  def finished?
    self.blueprint.finished?(active_step)
  end

  def failed?
    self.status == 'failed'
  end


  def step_finished?(step_number)
    step_number < active_step || self.blueprint.step_finished?(step_data(step_number))
  end


  def step_data(step_number)
     step = DeploymentStepDatum.find_by_deployment_id_and_step(self.id,step_number) 
     unless step
       step = DeploymentStepDatum.new(:deployment => self,:step => step_number)
       self.blueprint.initialize_step(step)
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
        begin
          self.blueprint.execute_step!(step_data(self.active_step))
        rescue StepException => e
          self.update_attributes( :status => 'failed',
                                 :failure_description => e.description)
          self.cloud.force_reset
        end
      end
    end
    true
  end


  def teardown!
    # Teardown the entire deployment
  end
  
  def machine_failed!(machine)
    self.blueprint.machine_failed!(step_data(machine.step),machine)
  end

  def machine_activated!(machine)
    self.blueprint.machine_activated!(step_data(machine.step),machine)
  end

end
