
class DeploymentStepDatum
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :deployment
  
  field :data, :type => Hash, :default => { }

  field :blueprint_identity_hash
  field :initialized, :type => Boolean, :default => false
  field :options_class_name

  attr_accessor :step,:substep

  def config 
    @config ||= options_class_name.constantize.new(self.data)
  end

  def update_config
    self.data = config.to_hash
  end

  def save_config
    self.update_config
    self.save
    @config = nil
  end
end
