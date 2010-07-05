
class Company 
   include SimplyStored::Couch

   property :name
   property :active,:type => :boolean, :default => true
   property :aws_key
   property :key_name
   property :aws_secret

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
      @ec2 ||=  AWS::EC2::Base.new(:access_key_id => self.aws_key, :secret_access_key => self.aws_secret)
   end


   def self.destroy_all_companies!
     Company.all.map(&:destroy)
   end
end
