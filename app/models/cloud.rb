


class Cloud < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :company

  field :name
  validates_presence_of :name

  has_many :machines
  has_many :deployments

  field :options_hash, :type => Hash, :default => {}
  field :chef_details, :type => Hash, :default => {}
  field :config_details, :type => Hash, :default => {}
  field :status, :default => 'normal' 
  field :active, :type => Boolean, :default => false
  field :current_deployment_id

  has_options :status, [["Normal","normal"],["Deploying","deploying"]]

  class Options < HashModel
    attributes :security_group => 'default', :availability_zone => 'us-east-1a'
    has_options :availability_zone, 
       ['us-east-1a','us-east-1b','us-east-1c','us-east-1d']
  end

  class ChefOptions < HashModel
    attributes :repository => nil, :branch => 'HEAD', :redeploy => false, :gems => '', :modules_list => '', :gitkey => '', :ssl_private_key_value => '',:certificate_value => ''

    def certificate=(val)
      @certificate_value = val unless val.strip.blank?
    end

    def certificate; nil; end
    def has_certificate?; !self.certificate_value.blank?; end

    def private_key=(val)
      @ssl_private_key_value = val unless val.strip.blank?
    end

    def private_key; nil; end
    def has_private_key?; !self.ssl_private_key_value.blank?; end



    def module_array
      self.modules_list.strip.split("\n").map(&:strip).reject(&:blank?).map { |elm|
        md,branch = elm.split(",")
        branch ||= "origin/master"
        if !(md =~ /git\@/)
          name = md.to_s.downcase
          md = "git://github.com/cykod/Webiva-#{md}.git"
          [ name , md, branch ]
        else
          md =~ /webiva\-([a-zA-Z0-9_]+)$/
          name = $1
          [ name, md, branch ]
        end
      }
    end

    def gems_array
        self.gems.strip.split("\n").map(&:strip).reject(&:blank?).map { |elm|
          elm,version = elm.split(",")
          [ elm, version ]
        }
    end

    def cloud_hash
      self.to_hash.merge(:module_list => self.module_array,
                         :gems => self.gems_array
                        )
    end
  end

  class ConfigOptions < HashModel
    attributes :db_user => nil, :db_user_password => nil, :migrator_user => nil, :migrator_user_password => nil
  end

  def config(val=nil)
    return @config_options if @config_options && !val
    @config_options = ConfigOptions.new(val || self.config_details)
  end

  def config=(val)
    self.config_details = config(val).to_hash
  end

  def initialize_database_passwords!
   config.db_user = 'webiva_u'
   config.db_user_password = BaseModel.generate_hash[0..14]
   config.migrator_user= master_db.master_username
   config.migrator_user_password = master_db.master_password
   self.config_details = config.to_hash
   save
  end

  def chef_options(val=nil)
    return @chef_options if @chef_options && !val
    @chef_options = ChefOptions.new(val  ? self.chef_details.merge(val) : self.chef_details)
  end

  def chef_options=(val)
    self.chef_details = chef_options(val).to_hash
  end

  def save_cloud_databag(opts=nil)
    client = ChefClient.new 
    client.save_databag(self,'cloud',(opts || self.chef_options).cloud_hash)
  end

  def force_redeploy
    opts = chef_options
    opts.redeploy = true
    save_cloud_databag(opts)
  end

  def unforce_redeploy
    opts = chef_options
    opts.redeploy = false
    save_cloud_databag(opts)
  end

  def active_deployment_list(page=1)
    deps = Deployment.where(:cloud_id => self.id, :noted => nil).all
    deps.sort { |a,b| b.created_at <=> a.created_at }
  end

  def cleanup_deployments!
    self.active_deployment_list.each do |deployment|
      deployment.update_attributes(:noted => true) if deployment.deployed? || deployment.failed?
    end
  end

  def cloud_machines(machine_ids)
    (machine_ids||[]).map do |mid|
      self.cloud_machine(mid)
     end.compact
  end

  def active_machines
    self.machines.select { |m| m.active? }
  end

  def machine_options
    self.active_machines.sort { |a,b| a.instance_type <=> b.instance_type }.map { |m| [ "#{m.instance_type_display}: #{m.full_name}", m.id ] }
  end


  def cloud_machine(machine_id)
    machine = Machine.find(machine_id)
    machine && machine.cloud_id == self.id ? machine : nil
  end

  def server_select_options
    self.machines.select { |m| m.server? }.map { |m| [ m.full_name, m.id ] }
  end

  def machines_by_role(role)
    role = role.to_s
    self.machines.select(&:active?).select { |m| m.roles.include?(role) }
  end

  def machine_by_role(role)
     machines_by_role(role)[0]
  end

  def count_by_role(role)
    machines_by_role(role).length
  end

  def can_deploy?
    self.status =='normal'
  end

  def can_activate?
    count_by_role('web') > 0 &&
      count_by_role('migrator') == 1 &&
      count_by_role('cron') == 1 &&
      count_by_role('master_db') == 1 &&
      count_by_role('memcache') > 0 &&
      count_by_role('workling') > 0 &&
      count_by_role('starling') > 0
  end

  def refresh_machine_status!
    self.machines.each do |machine|
      machine.check_status! 
    end
  end

  def update_active_state!
    could_activate = self.can_activate?
    if could_activate != self.active
      self.active = could_activate
      # TODO: Make some sort of notification
      self.save
    end
  end
  
  def live_machines
    self.machines.select { |m| !m.terminated? }
  end

  def servers
    self.live_machines.select { |m| m.server? }
  end

  # Return a single machine
  def master_db; machine_by_role('master_db'); end  
  def load_balancer; machine_by_role('balancer'); end
  def migrator; machine_by_role('migrator'); end

  # Return lists of machines
  def web_servers; machines_by_role('web'); end
  def queue_servers; machines_by_role('starling'); end
  def memcache_servers; machines_by_role('memcache'); end

  def deploy(input_deployment) #blueprint, deployment_parameters)
    if self.status == 'normal'
      self.status = 'deploying'
      if self.save
        deployment = Deployment.create(
            :blueprint => input_deployment.blueprint, 
            :deployment_options => input_deployment.deployment_options.to_hash,
            :cloud => self,
            :company => self.company,
            :skip_cloud_check => true)
        self.current_deployment_id = deployment.id
        if deployment.valid? && self.save
          deployment.takeover_machines!(input_deployment.affected_machines)
          deployment.execute! 
        end
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

  def config(val=nil)
    return @config if @config && !val
     @config = Options.new(val || self.options_hash)
  end

  def config=(val)
     self.options_hash = self.config(val).to_hash
  end


end
