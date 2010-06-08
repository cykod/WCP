
class Company 
   include SimplyStored::Couch

   property :name
   property :aws_key
   property :key_name
   property :aws_secret

   has_many :deployments, :dependent => :destroy
   has_many :clouds, :dependent => :destroy
   has_many :machines

   def add_cloud(name)
     Cloud.create(:name => name, :company => self)
   end

   def ec2
      @ec2 ||=  AWS::EC2::Base.new(:access_key_id => self.aws_key, :secret_access_key => self.aws_secret)
   end


end
