

class MachineBlueprint < BaseModel
  include SimplyStored::Couch

  has_many :machines

  property :name
  property :identifier

  property :launcher_class

  property :instance_type
  property :login_user, :default => 'ubuntu'

  property :options_data, :type => Hash, :default => {}

  before_save :set_instance_type

  has_options :instance_type, [["EC2 Server", "ec2"],["Load Balancer","balancer"],["Database","rds"]]

  validates :name, :presence => true
  validates :identifier, :format =>  { :with => /^[a-zA-Z\-_0-9]+$/ }
  
  has_options :instance_type, Machine.instance_type_original_options
  
  def launcher
     @launcher ||= self.launcher_class.camelcase.constantize
  end

  class Options < HashModel

  end

  def parameters
    launcher.machine_parameters.uniq
  end

  def parameters_list
    parameters.map { |elm| elm[0] }
  end

  def options(opts=nil)
    return @options_object if @options_object && !opts
    @options_object = Options.new(opts || self.options_data)
    @options_object.additional_vars(self.parameters_list)
    @options_object
  end

  def options=(val)
    self.options_data = options(val).to_hash
  end


  def launcher_name
    launcher.machine_launcher_name
  end

  def launcher_description 
    launcher.description(self)
  end

  def launcher_instance_type
    launcher.machine_launcher_options[:instance_type] || 'ec2'
  end
   
  def self.fetch(identifier)
    self.find_by_identifier(identifier)
  end
  
  def self.select_options(elements=nil)
    (elements||self.all).map { |b| [ b.name,b.identifier ] }
  end

  def self.rds_select_options
    self.select_options(self.all.select { |b| b.instance_type == 'rds' })
  end

  def self.rds_server_select_options
    self.select_options(self.all.select { |b| b.launcher.to_s == "Machines::RdsServer" })
  end

  def self.rds_restore_select_options
    self.select_options(self.all.select { |b| b.launcher.to_s == "Machines::RdsServerSnapshot" })
  end

  def self.ec2_select_options
    self.select_options(self.all.select { |b| b.instance_type == 'ec2' })
  end

  def self.elb_select_options
    self.select_options(self.all.select { |b| b.instance_type == 'balancer' })
  end

 def self.machine_directories
    [ Rails.root.join("app/plans/machines/*") ]
  end


  def self.launcher_class_options
    opts = []
    machine_directories.each do |dir|
      Dir.glob(dir).each do |filepath|
        if File.extname(filepath)== '.rb'
          fl = (filepath.gsub((dir.to_s+"/").gsub("/*",""),"")).gsub(/\.rb$/,'')
          if fl != "base" 
            cls = "Machines::#{fl.camelcase}"
            opts << [ cls.constantize.machine_launcher_name, cls.underscore ] 
          end
        end
      end
    end
    opts
  end

  
  
  protected

  def set_instance_type
    self.instance_type = self.launcher_instance_type
  end
end
