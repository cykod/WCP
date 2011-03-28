

class BlueprintStep
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :blueprint
  field :identity_hash
  field :position, :type => Fixnum
  field :substep, :type => Fixnum
  field :name
  field :step_class_name
  field :step_options_class_name

  def initialize_step_data(step_data)
   step_data.options_class_name = self.step_options_class_name 
   step_data.initialized = true
   step_data.save
  end

  def step_class_object
     self.step_class_name.constantize
  end

  def step_class(deployment)
    @step_class ||= self.step_class_object.new(deployment,blueprint)
  end

  def step_name
    self.step_class_name.constantize.step_name
  end

  def finished?(step_data)
    step_class(step_data.deployment).finished?(step_data).tap { step_data.save_config }
  end

  def execute!(step_data)
    step_class(step_data.deployment).execute!(step_data).tap { step_data.save_config } 
  end

  def machine_failed!(step_data)
    step_class(step_data.deployment).machine_failed!(step_data,machine).tap { step_data.save_config }
  end

  def machine_activated!(step_data,machine)
    self.step_class(step_data.deployment).machine_activated!(step_data,machine).tap { step_data.save_config }
  end

  def self.steps_directories
    [ Rails.root.join("app/plans/steps/**/*") ]
  end

  def self.check_step_identifier(identifier)
    cls = self.available_step_options.detect { |st| st[1] == identifier }
    cls ? cls[1].camelcase : nil
  end

  def self.available_step_options
    opts = []
    steps_directories.each do |dir|
      Dir.glob(dir).each do |filepath|
        if File.extname(filepath)== '.rb'
          fl = (filepath.gsub((dir.to_s+"/").gsub("/**/*",""),"")).gsub(/\.rb$/,'')
          if fl != "base" 
            cls = "Steps::#{fl.camelcase}"
            opts << [ cls.constantize.step_name, cls.underscore ] 
          end
        end
      end
    end
    opts.sort { |a,b| a[0] <=> b[0] }
  end

end
