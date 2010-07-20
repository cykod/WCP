class ChefClient

  attr_reader :client

 def initialize
     @client = Chef::REST.new(Server.local_server_url,Server.authorized_client_user,Server.authorized_client_pem_file)
  end


  def add_to_run_list(machine,recipes)
    node = @client.get_rest('/nodes/' + machine.private_hostname)

    recipes.each do |recipe|
      node['run_list'] << "recipe[#{recipe}]" unless node['run_list'].include?( "recipe[#{recipe}]")
    end

    @client.put_rest('/nodes/' + machine.private_hostname,node)
  end

  def run_chef_client(machine_list)
    Net::SSH::Multi.start do |session|
      machine_list.each do |server|
        server.multi_ssh(session)
      end

      session.exec("sudo /var/lib/gems/1.8/bin/chef-client")
      session.loop
    end
  end

end
