
# ssh webiva@cykodcore.cykod.com -R 4000:127.0.0.1:4000

class Machine < BaseModel
  include SimplyStored::Couch

  belongs_to :cloud
  belongs_to :deployment
  belongs_to :company
  belongs_to :machine_blueprint
  has_many :launch_monitors, :dependent => :destroy

  property :name
  property :step, :type => Fixnum
  property :status 
  property :roles, :type => Array, :default => []
  property :launcher_class

  property :state_data, :type => Hash, :default => {}

  property :instance_id
  property :machine_image
  property :private_hostname
  property :hostname
  property :ip_address
  property :private_ip_address
  property :instance_type
  property :instance_size
  property :root_user

  property :master_username
  property :master_password

  before_create :initialization_details

  has_options :instance_type, [["EC2 Server", "ec2"],["Load Balancer","balancer"],["Database","rds"]]
  has_options :status, [['Created','created'],['Launching','launching'],['Active','active'],['Launched','launched'],['Terminating','terminating'],['Terminated','terminated']]

  @@role_names = { 'web' => "Web",
                   'balancer' => "Load Balancer",
                   'migrator' => 'Migrator',
                   'master_db' => 'Master DB',
                   'domain_db' => 'Domain DB',
                   'slave_db' => 'Slave DB',
                   'memcache' => 'Memcached',
                   'starling' => 'Queue',
                   'workling' => 'Workling',
                   'cron' => 'Cron' }

  def server?
    self.instance_type == 'ec2'
  end

  def memcache?; self.roles.include?('memcache'); end
  def starling?; self.roles.include?('starling'); end
  def master_db?; self.roles.include?('master_db') && self.instance_type == 'rds'; end
  def migrator?; self.roles.include?('migrator') && self.server?; end
  def web_server?; self.roles.include?('web'); end
  def workling_server?; self.roles.include?('workling'); end
  def load_balancer?; self.instance_type == 'balancer' && self.roles.include?('balancer'); end

  def roles_display
    self.roles.map { |rl| @@role_names[rl] }.compact.to_sentence
  end

  def full_name
    if self.name.blank?
     "#{self.launcher_class.to_s.titleize} - #{self.instance_id}"
    else
      self.name
    end
  end

  def initialize_rds_options(pw,username=nil)
    self.master_username = username || "Webiva" + BaseModel.generate_hash[0..8]
    self.master_password = pw
  end

  def save_chef_node_information(restart=false)
    c = ChefClient.new
    c.save_attributes(self,{ 'wcp' => 
                           { 'cloud' => self.cloud_id, 'deployment' => self.deployment_id,
                             'ip_address' => self.ip_address,
                             'hostname' => self.hostname,
                             'roles' => self.roles,
                             'restart' => restart,
                             'starling_restart' => restart ? self.starling? : false
                           }})

  end

  protected

  def initialization_details
    self.launcher_class = self.machine_blueprint.launcher_class
    self.instance_type = self.machine_blueprint.instance_type
    self.status = 'created'
  end
  
  public


  def launch!
    if self.status == 'created'
      self.status = 'launching'
      if self.save
        returning execute_launch! do 
          monitor_launch!
        end
      end
    end
  end

  def ssh(&block)
    if block_given?
      ret = nil
      Net::SSH.start(self.ip_address,self.root_user,:key_data => [self.company.certificate]) do |ssh| 
        ret = yield ssh
      end
      ret
    else
      Net::SSH.start(self.ip_address,self.root_user,:key_data => [self.company.certificate])
    end
  end

  def multi_ssh(session)
    session.use "#{self.root_user}@#{self.ip_address}", :key_data =>  [self.company.certificate]
  end

  def ssh_exec(cmd)
    self.ssh do |s|
       s.exec!(cmd)
    end
  end

  def active?
    self.status == 'active'
  end

  def terminating?
    self.status =='terminating'
  end

  def terminated?
    self.status == 'terminated'
  end

  def launcher
    @launcher ||= self.launcher_class.camelcase.constantize.new(self)
  end

  def check_status!
    # Check AWS for status, update our state
    returning (self.status = launcher.check_status!) {  self.save }
  end


  def terminate!
    if self.active?
      self.status = 'terminating'
      if self.save
        launcher.terminate!
      end
      monitor_launch!
    end
  end

  private 

  def execute_launch!
    launcher.launch! 
  end


  def monitor_launch!
    monitor = LaunchMonitor.run_monitor!(self)
  end
end
