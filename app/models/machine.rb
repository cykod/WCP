

class Machine
  include SimplyStored::Couch

  belongs_to :cloud
  belongs_to :deployment
  belongs_to :company
  belongs_to :machine_blueprint

  property :name
  property :status 
  property :roles, :type => Array, :default => []
  property :launcher_class

  property :configuration_info, :type => Hash, :default => {}

  property :instance_id
  property :machine_id
  property :hostname
  property :instance_type

  before_create :initialization_details

  protected

  def initialization_details
    self.launcher_class = self.machine_blueprint.launcher_class
    self.machine_id = self.machine_blueprint.machine_id
    self.instance_type = self.machine_blueprint.instance_type
    self.status = 'created'
  end
  
  public


  def launch
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
    self.status == 'launched'
  end

  def launcher
    @launcher ||= self.launcher_class.constantize.new(self)
  end

  def check_status!
    launcher.check_status!
    # Check AWS for status, update our state
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
