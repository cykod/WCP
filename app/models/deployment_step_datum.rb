


class DeploymentStepDatum

  belongs_to :deployment
  
  property :data, :type => Hash, :default => { }

  property :step, :type => Fixnum
  property :initialized, :type => :boolean, :default => false
  property :options_class_name

  before_save :update_options

  def options
    @options ||= options_class_name.constantize.new(self.data)
  end

  def update_options
    self.data = options.to_hash
  end
end
