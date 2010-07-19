

class MachineBlueprint < BaseModel
  include SimplyStored::Couch

  has_many :machines

  property :name
  property :identifier

  property :launcher_class

  property :instance_type
  property :machine_image

  before_save :set_instance_type

  has_options :instance_type, [['EC2 Server','server'],
                               ['Database Server','rds'],
                               ['Load Balancer','balancer']]
  def launcher
     @launcher ||= self.launcher_class.camelcase.constantize
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
