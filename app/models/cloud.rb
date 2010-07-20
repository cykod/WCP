


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

  class Options < HashModel
    attributes :security_group => 'default', :availability_zone => 'us-east-1a'

    has_options :availability_zone, 
       ['us-east-1a','us-east-1b','us-east-1c','us-east-1d']
  end

  def deployment_list(page=1)
    self.deployments.sort { |a,b| b.created_at <=> a.created_at }
  end

  def cloud_machines(machine_ids)
    (machine_ids||[]).map do |mid|
      self.cloud_machine(mid)
     end.compact
  end

  def cloud_machine(machine_id)
    machine = Machine.find(machine_id)
    machine && machine.cloud_id == self.id ? machine : nil
  end

  def server_select_options
    self.machines.select { |m| m.server? }.map { |m| [ m.full_name, m.id ] }
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

  def options(val=nil)
    return @options if @options && !val
     @options = Options.new(val || self.options_hash)
  end

  def options=(val)
     self.options_hash = self.options(val).to_hash
  end


end
