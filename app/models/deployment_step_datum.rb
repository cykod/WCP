
class DeploymentStepDatum
  include SimplyStored::Couch

  belongs_to :deployment
  
  property :data, :type => Hash, :default => { }

  property :blueprint_identity_hash
  property :initialized, :type => :boolean, :default => false
  property :options_class_name

  attr_accessor :step,:substep

  view :by_deployment_id_and_blueprint_identity_hash, :key => [:deployment_id, :blueprint_identity_hash]

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
