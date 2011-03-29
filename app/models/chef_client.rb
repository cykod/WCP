class ChefClient

  attr_reader :client

 def initialize
     @client = Chef::REST.new(Server.local_server_url,Server.authorized_client_user,Server.authorized_client_pem_file)
  end

  def save_attributes(machine,attributes)
    node = @client.get_rest('nodes/' + machine.private_hostname)
    
    node['normal'] ||= {}
    node['normal'] = (node['normal']||{}).merge(attributes)

    @client.put_rest('nodes/' + machine.private_hostname,node)
  end


  def add_to_run_list(machine,recipes)
    node = @client.get_rest('nodes/' + machine.private_hostname)

    recipes.each do |recipe|
      node['run_list'] << recipe unless node['run_list'].include?( recipe )
    end

    @client.put_rest('nodes/' + machine.private_hostname,node)
  end

  def save_databag(object,item,data)
    data['id'] = item
    @client.post_rest("data", { "name" => object.id }) rescue Net::HTTPServerException

    begin
      @client.post_rest("data/#{object.id}", data)
    rescue Net::HTTPServerException => e
      @client.put_rest("data/#{object.id}/#{item}",data)
    end
  end


  def find_role(name)
    begin
      return @client.get_rest("roles/#{name}")
    rescue Net::HTTPServerException => e
      nil
    end
  end

  def new_role(name,description)
     {
      "name"=> name,
      "chef_type"=> "role",
      "json_class"=> "Chef::Role",
      "default_attributes"=> { },
      "description"=> description,
      "run_list"=> [ ],
      "override_attributes"=> {  }
    }

  end

  def create_role(role)
    @client.post_rest('roles',role)
  end

  def save_role(role)
    @client.put_rest("roles/#{role['name']}",role)
  end

  def delete_node(machine)
    @client.delete_rest("nodes/#{machine.private_hostname}")
  end

end
