
class Deployment < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :company
  belongs_to :cloud
  belongs_to :blueprint

  attr_accessor :create_execute

  field :active_step, :type => Fixnum, :default => -1
  field :completed_step, :type => Fixnum, :default => -1

  field :deployment_options_data, :type => Hash, :default => {}
  field :data, :type => Hash, :default => {}
  field :timeout_date, :type => Time
  field :status, :default => 'created'
  field :failure_description 

  field :noted, :type => Boolean, :default => false

  has_many :machines
  has_many :deployment_logs, :dependent => :destroy
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

  def log(msg)
    @log ||= []
    @log << msg
  end

  def display_log
    self.deployment_logs.desc(:created_at)
  end

  def write_log
    if(@log && @log.length > 0) 
      log_msgs = self.deployment_logs.create(:messages => @log)
      @log = []
      log_msgs
    else
      nil
    end
  end


  def multi_ssh(servers,cmd)
    session = Net::SSH::Multi.start 

    servers.each do |server|
      server.multi_ssh(session)
    end

    log_cnt = 0

    session.exec(cmd) do |ch,stream,data|
      log("[#{ch[:host]} : #{stream}] #{data}")
      log_cnt += 1
      write_log if(log_cnt % 10 == 0) 
    end
    write_log

    session.loop
    session.close 
  end

  def ssh_chef_client(ssh)
      ssh_log_exec(ssh,"sudo /var/lib/gems/1.8/bin/chef-client")
  end

  def ssh_log_exec(ssh,cmd) 
    log_cnt = 0
    ssh.exec(cmd) do |ch,stream,data|
      log("[#{ch[:host]} : #{stream}] #{data}")
      log_cnt += 1
      write_log if(log_cnt % 10 == 0) 
    end
    write_log
  end

  def run_chef_client(servers)
    multi_ssh(servers,"sudo /var/lib/gems/1.8/bin/chef-client")
  end

  def takeover_machines!(machine_ids)
    victims = self.cloud.cloud_machines(machine_ids) 
    victims.each do |v|
      v.update_attributes(:deployment_id => self.id)
    end
    self.reload
  end

  def servers
    self.machines.select { |m| m.server? }
  end

  def migrator
    self.machines.select { |m| m.active? }.detect { |m| m.migrator? } 
  end

  def web_servers
    self.servers.select { |m| m.roles.include?('web') } 
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
    self.deployment_options_data = self.blueprint.config(val).to_hash
  end

  def deployment_options
    self.blueprint.config(self.deployment_options_data)
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

    step = self.deployment_step_data.where(:blueprint_identity_hash => identity_hash).first
    unless step
      step = self.deployment_step_data.build(:blueprint_identity_hash => identity_hash)
    end
    step.step = blueprint_step.position
    step.substep = blueprint_step.substep
    self.blueprint.initialize_step(step)
    step.deployment = self
    step
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
    self.completed_step = step_number - 1
    self.active_step = step_number
    if self.save
      if self.finished?
        self.finish!
        return false
      else
        begin
          self.log("Executing Step: #{step_number}")
          self.blueprint.execute_step!(step_data(self.active_step))
          self.log("Executed Step: #{step_number}")
          self.write_log
        rescue StepException => e
          self.write_log
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
