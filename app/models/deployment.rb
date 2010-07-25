
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

  property :noted, :type => :boolean, :default => nil

  has_many :machines
  has_many :deployment_step_data, :dependent => :destroy
  has_many :deployment_monitors, :dependent => :destroy

  validates_presence_of :blueprint
  validates_presence_of :cloud

  validate :can_deploy, :on => :create
  attr_accessor :skip_cloud_check

  attr_accessor :affected_machines

  has_options :status, [['Deploying','deploying'],['Deployed','deployed'],['Created','created'],['Failed','failed']]

  def add_machine(roles,blueprint,options={})
    Machine.create(
        { 
          :step => self.active_step,
          :deployment => self,
          :roles => roles.map(&:to_s), 
          :machine_blueprint => blueprint, 
          :company => self.company,
          :cloud => cloud
        }.merge(options)
    )
  end

  def can_deploy
    if !skip_cloud_check && self.cloud && !self.cloud.can_deploy?
     self.errors.add(:cloud,"Cloud is not ready to deploy")
    end
  end

  def takeover_machines!(machine_ids)
    victims = self.cloud.cloud_machines(machine_ids) 
    victims.each do |v|
      v.update_attributes(:deployment_id => self.id)
    end
  end

  def servers
    self.machines.select { |m| m.server? }
  end

  def active_step_name
    step = self.blueprint.steps[self.active_step] 
    if step
      "#{step.step_name} (#{step.substep})"
    else 
      "None"
    end
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

  def deployed?
    self.status == 'deployed'
  end

  def failed?
    self.status == 'failed'
  end


  def step_finished?(step_number)
    step_number < active_step || self.blueprint.step_finished?(step_data(step_number))
  end


  def step_data(step_number)
    blueprint_step = self.blueprint.steps[step_number]
    identity_hash = blueprint_step.identity_hash

    step = DeploymentStepDatum.find_by_deployment_id_and_blueprint_identity_hash(self.id,identity_hash) 
    unless step
      step = DeploymentStepDatum.new(:deployment_id => self.id,:blueprint_identity_hash => identity_hash)
    end
    step.step = blueprint_step.position-1
    step.substep = blueprint_step.substep
    self.blueprint.initialize_step(step)
  end

  def finish!
    self.status = 'deployed'
    self.cloud.deployment_finished!
    self.save
  end

  # Primarily for testing
  def force_step(step_number)
    execute_step!(step_number)
    step_finished?(step_number)
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
#        rescue Exception => e
#          self.update_attributes( :status => 'failed',
#                                 :failure_description => e.to_s)
#          self.cloud.force_reset
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
