class Blueprint < BaseModel
  include SimplyStored::Couch

  property :name
  property :options_class
  property :blueprint_options_data, :type => Hash, :default => {}

  validates_presence_of :name
  validates_presence_of :options_class

  has_many :blueprint_steps

  def initialize_step(step_data)
    if !step_data.initialized?
      self.steps[step_data.step].initialize_step_data(step_data)
    end
    step_data
  end

  def options_instance
    @options_instance ||= self.options_class.constantize.new(self)
  end

  def blueprint_options=(val)
    self.blueprint_options_data = blueprint_options(val).to_hash
  end

  def blueprint_options(opts=ni)
     options_instance.blueprint_options(opts || blueprint_options_data)
  end

  def self.blueprints_directories
    [ Rails.root.join("app/plans/blueprints/**") ]
  end

  def self.options_class_options
    opts = []
    blueprints_directories.each do |dir|
      Dir.glob(dir).each do |filepath|
        fl = File.basename(filepath,".rb")
        if fl != "base"
          cls = "Blueprints::#{fl.camelcase}"
          opts << [ cls.constantize.blueprint_name, cls.underscore ] 
        end
      end
    end
    opts
  end
  
  def options(opts)
    options_instance.options(opts)
  end

  def options_partial
    options_instance.options_partial
  end

 def add_step(name,step_class_name)
    
    self.reload
    cls = step_class_name.constantize


    next_position = self.steps[-1] ? self.steps[-1].position + 1 : 0
    substeps = cls.step_info_details[:substeps]
    (0..substeps-1).each do |substep|
      BlueprintStep.create(:name => name,
                            :position => next_position,
                            :substep => substep,
                            :blueprint_id => self.id,
                            :step_class_name => step_class_name,
                            :step_options_class_name => cls.step_info_details[:options])

      next_position += 1
    end
    self.reload
  end

 def finished?(step_number)
   step_number >= self.steps.length
 end
  
  def step_finished?(step_data)
    self.steps[step_data.step].finished?(step_data)
  end

  def execute_step!(step_data)
    if step_data.step > self.steps.length
      return false
    else
      self.steps[step_data.step].execute!(step_data)
    end
  end

  def machine_failed!(step_data,machine)
    self.steps[step_data.step].machine_failed!(step_data,machine)
  end

  def machine_activated!(step_data,machine)
    self.steps[step_data.step].machine_activated!(step_data,machine)
  end

  def steps
    self.blueprint_steps.sort { |a,b| a.position <=> b.position }
  end
  
end
