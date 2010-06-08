

class Step

  attr_reader :company, :deployment, :deployment_blueprint, :cloud

 def initialize(deployment,deployment_blueprint)
    @deployment = deployment
    @company = deployment.company
    @cloud = deployment.cloud
    @deployment_blueprint = deployment_blueprint
 end

end
