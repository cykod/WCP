

class MachineBlueprint < BaseModel
  include SimplyStored::Couch

  has_many :machines

  property :name
  property :identifier

  property :launcher_class

  property :instance_type
  property :instance_size
  property :machine_image
  property :root_user, :default => 'ubuntu'

  property :options_data, :type => Hash, :default => {}

  before_save :set_instance_type

  validates :identifier, :format =>  { :with => /^[a-zA-Z\-_0-9]+$/ }
  
  has_options :instance_size, ['m1.small','m1.large','m1.xlarge','m2.xlarge','m2.2xlarge','m2.4xlarge','c1.medium','c1.xlarge', 'cc1.4xlarge' ]

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

  def launcher_instance_type
    launcher.machine_launcher_options[:instance_type] || 'server'
  end
   
  def self.fetch(identifier)
    self.find_by_identifier(identifier)
  end
  
  def self.select_options
    self.all.map { |b| [ b.name,b.identifier ] }
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
