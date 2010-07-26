
class Steps::Terminate::DeleteChefNodes < Steps::Base

  step_info "(T3) Delete the server nodes from Chef Server"

  class Options < HashModel
    
  end

  def execute!(step)
    servers = deployment.servers
    client = ChefClient.new
    servers.each do |machine|
      client.delete_node(machine)
    end
  end

end
