

class Step

  attr_reader :company, :deployment, :deployment_blueprint, :cloud

 def initialize(deployment,deployment_blueprint)
    @deployment = deployment
    @company = deployment.company
    @cloud = deployment.cloud
    @deployment_blueprint = deployment_blueprint
 end
  
 def self.step_info(options={})
    sing = class << self; self; end
    options[:substeps] ||= 1
    options[:options] ||= "#{self.class.to_s}::Options"
    sing.send :define_method, "step_info_details" do
     options 
    end
 end

end
