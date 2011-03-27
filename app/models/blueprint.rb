class Blueprint < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :blueprint_options_data, :type => Hash, :default => {}

  validates_presence_of :name

  has_many :blueprint_steps

  def initialize_step(step_data)
    if !step_data.initialized?
      self.steps[step_data.step].initialize_step_data(step_data)
    end
    step_data
  end

  class Options < HashModel

  end

  def blueprint_parameters
    self.steps.inject([]) do |elems,step|
      elems + step.step_class_object.blueprint_parameters
    end.uniq
  end

  def parameters
    self.steps.inject([]) do |elems,step|
      elems + step.step_class_object.deployment_parameters
    end.uniq
  end

  def blueprint_parameters_list
    self.blueprint_parameters.map { |elm| elm[0] }
  end

  def parameters_list 
    self.parameters.map { |elm| elm[0] }
  end

  def blueprint_options=(val)
    self.blueprint_options_data = blueprint_options(val).to_hash
  end

  def blueprint_options(opts=nil)
     opts = Options.new(opts || blueprint_options_data)
     opts.additional_vars(self.blueprint_parameters_list)
     opts
  end

  def config(opts)
    opts = Options.new(opts)
    opts.additional_vars(self.parameters_list)
    opts
  end

 def add_step(name,step_class_name)
    
    self.reload
    cls = step_class_name.constantize

    original_blueprint_step_hash = nil

    next_position = self.steps[-1] ? self.steps[-1].position + 1 : 0
    substeps = cls.step_info_details[:substeps]
    (0..substeps-1).each do |substep|
      step = BlueprintStep.create(:name => name,
                            :position => next_position,
                            :identity_hash => original_blueprint_step_hash,
                            :substep => substep,
                            :blueprint_id => self.id,
                            :step_class_name => step_class_name,
                            :step_options_class_name => cls.step_info_details[:options])

      if original_blueprint_step_hash.blank?
        original_blueprint_step_hash = step.id.to_s
        step.update_attributes(:identity_hash => original_blueprint_step_hash)
      end
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

  def resort_steps!
    self.steps.each_with_index do |step,idx|
      step.update_attributes(:position => idx + 1)
    end

  end

  def steps
    self.blueprint_steps.sort { |a,b| a.position <=> b.position }
  end
  
end
