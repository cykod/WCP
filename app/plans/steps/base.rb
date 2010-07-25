

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
    options[:options] ||= "#{self.to_s}::Options"
    sing.send :define_method, "step_info_details" do
     options 
    end
 end

 def self.blueprint_parameters
   []
 end

 def self.parameter(name,opts = {})
   sing = class << self; self; end
 
   current_parameters = self.blueprint_parameters
   current_parameters << [ name.to_sym, opts ] 
   
   sing.send(:define_method,:blueprint_parameters) do 
     current_parameters
   end
 end

 def self.deployment_parameters
   []
 end

 def self.deployment_parameter(name,opts = {})
   sing = class << self; self; end
 
   current_parameters = self.deployment_parameters
   current_parameters << [ name.to_sym, opts ] 
   
   sing.send(:define_method,:deployment_parameters) do 
     current_parameters
   end
 end

 def fail_step(description)
   raise StepException, description
 end

  def machine_failed!(step,machine)
  end


  def machine_activated!(step,machine)
   #
  end

  def finished?(step); true; end

end
