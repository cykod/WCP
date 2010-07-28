require 'yaml'

class Server < BaseModel

  def self.info_hash
    @@info_hash ||= YAML.load_file(Rails.root.join("config","config.yml"))
  end
  

  def self.external_server_url
    info_hash['external_server_url']
  end

  def self.validation_pem_file
    info_hash['validation_pem_file'] 
  end
   

  def self.local_server_url
    info_hash['local_server_url']
  end


  def self.authorized_client_user
    info_hash['authorized_client_user']
  end


  def self.authorized_client_pem_file
    info_hash['authorized_client_pem_file']
  end

end
