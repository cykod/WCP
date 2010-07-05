


class DeploymentStepDatum
  include SimplyStored::Couch

  belongs_to :deployment
  
  property :data, :type => Hash, :default => { }

  property :step, :type => Fixnum
  property :substep, :type => Fixnum
  property :initialized, :type => :boolean, :default => false
  property :options_class_name

  view :by_deployment_id_and_step, :ley => [:deployment_id, :step]

  def options
    @options ||= options_class_name.constantize.new(self.data)
  end

  def update_options
    self.data = options.to_hash
  end

  def save_options
    self.update_options
    self.save
  end
end
