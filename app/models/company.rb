
class Company < BaseModel
  include Mongoid::Document
  include Mongoid::Timestamps

   field :name
   field :active,:type => Boolean, :default => true
   field :aws_key
   field :key_name
   field :aws_secret
   field :certificate, :type => String

   validates_presence_of :name

   has_many :deployments, :dependent => :destroy
   has_many :clouds, :dependent => :destroy
   has_many :users, :dependent => :destroy
   has_many :machines

   def add_cloud(name)
     Cloud.create(:name => name, :company => self)
   end

  def company_cloud(cloud_id)
    cloud = Cloud.find(cloud_id)
    cloud && cloud.company_id == self.id ? cloud : nil
  end

  def ec2
    @ec2 ||= RightAws::Ec2.new(self.aws_key, self.aws_secret)
  end

  def rds
    @rds ||= RightAws::RdsInterface.new(self.aws_key, self.aws_secret)
  end

  def elb
    @elb ||= RightAws::ElbInterface.new(self.aws_key, self.aws_secret)
  end


  def self.destroy_all_companies!
    Company.all.map(&:destroy)
  end
end
