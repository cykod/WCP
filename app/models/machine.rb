

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

  property :configuration_info, :type => Hash, :default => {}

  property :instance_id
  property :machine_image
  property :hostname
  property :instance_type

  before_create :initialization_details

  has_options :instance_type, [["App Server", "ec2"],["Load Balancer","load_balancer"],["Database","rds"]]
  has_options :status, [['Created','created'],['Launching','launching'],['Active','active']]

  @@role_names = { 'web' => "Web",
                   'deployment' => 'Deployment',
                   'master_db' => 'Master DB',
                   'domain_db' => 'Domain DB',
                   'slave_db' => 'Slave DB',
                   'memcache' => 'Memcache',
                   'starling' => 'Background Queue',
                   'workling' => 'Workling',
                   'cron' => 'Cron' }



  def roles_display
    self.roles.map { |rl| @@role_names[rl] }.compact.to_sentence

  end

  protected

  def initialization_details
    self.launcher_class = self.machine_blueprint.launcher_class
    self.machine_image = self.machine_blueprint.machine_image
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


  def active?
    self.status == 'active'
  end

  def launcher
    @launcher ||= self.launcher_class.constantize.new(self)
  end

  def check_status!
    # Check AWS for status, update our state
    returning (self.status = launcher.check_status!) {  self.save }
  end


  def terminate!
    launcher.terminate!
  end

  private 

  def execute_launch!
    launcher.launch! 
  end


  def monitor_launch!
    monitor = LaunchMonitor.run_monitor!(self)
  end
end
