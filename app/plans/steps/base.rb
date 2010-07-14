

class Steps::Base

 attr_reader :company, :deployment, :blueprint, :cloud

 def initialize(deployment,blueprint)
    @deployment = deployment
    @company = deployment.company
    @cloud = deployment.cloud
    @blueprint = blueprint
 end
  
 def self.step_info(name,options={})
    sing = class << self; self; end
    sing.send(:define_method, :step_name) { name } 
    options[:substeps] ||= 1
    options[:options] ||= "#{self.class.to_s}::Options"
    sing.send :define_method, "step_info_details" do
     options 
    end
 end

end
