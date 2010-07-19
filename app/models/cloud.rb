


class Cloud < BaseModel
  include SimplyStored::Couch

  belongs_to :company

  property :name
  validates_presence_of :name

  has_many :machines
  has_many :deployments

  property :options_hash, :type => Hash, :default => {}
  property :status, :default => 'normal' 
  property :current_deployment_id

  has_options :status, [["Normal","normal"],["Deploying","deploying"]]

  attr_accessor :reset_cloud

  before_save :update_options
  before_save :auto_force_reset

  class Options < HashModel
    attributes :security_group => 'default', :availability_zone => 'us-east-1a'
  end

  def deployment_list(page=1)
    self.deployments.sort { |a,b| b.created_at <=> a.created_at }
  end

  def cloud_machine(machine_id)
    machine = Machine.find(machine_id)
    machine && machine.cloud_id == self.id ? machine : nil
  end

  def deploy(blueprint, deployment_parameters)
    if self.status == 'normal'
      self.status = 'deploying'
      if self.save
        deployment = Deployment.create(
            :blueprint => blueprint, 
            :deployment_options => deployment_parameters,
            :cloud => self,
            :company => self.company)
        self.current_deployment_id = deployment.id
        self.save
        deployment.execute! 
        deployment
      end
    end
  end

  def deployment_finished!
    if self.status == 'deploying'
      self.status = 'normal'
      self.save
    end
  end

  def force_reset
    self.status = 'normal'
    self.save
  end

  def destroy_cloud!
    self.machines.map(&:destroy)
    self.deployments.map(&:destroy)
    force_reset
  end

  # teardown the entire cloud
  def teardown!

  end

  def options
     @options ||= Options.new(self.options_hash)
  end

  protected

  def update_options
    self.options_hash = self.options.to_hash
  end

  def auto_force_reset
    if self.reset_cloud.to_s == '1'
      self.status = 'normal'
    end
  end

end
