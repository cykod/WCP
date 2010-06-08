


class Cloud
  include SimplyStored::Couch

  belongs_to :company

  property :name

  has_many :machines
  has_many :deployments

#  property :options_hash, :type => Hash, :default => {}
  property :status, :default => 'created' 

  # before_save :update_options

  class Options < HashModel
    attributes :security_group => 'default', :availability_zone => 'us-east-1a'
  end

  def deploy(deployment_blueprint, deployment_parameters)
    if self.status == 'created'
      self.status = 'deploying'
      if self.save
        deployment = self.deployments.create(:deployment_blueprint => deployment_blueprint, :deployment_parameters => deployment_parameters)
        deployment.execute! 
      end
    end
  end

  # teardown the entire cloud
  def teardown!

  end

  def options
     @options ||= Options.new(self.options_hash)
  end

  def update_options
    self.options_hash = self.options.to_hash
  end
end
