

class Server < BaseModel
  

  def self.external_server_url
    "http://cykodcore.cykod.com:4000"
  end

  def self.validation_pem_file
    "/etc/chef/public_validation.pem"
  end
   

  def self.local_server_url
    "http://localhost:4000"
  end


  def self.authorized_client_user
    "pascal"
  end


  def self.authorized_client_pem_file
    "/home/pascal/.chef/pascal.pem"
  end

end
