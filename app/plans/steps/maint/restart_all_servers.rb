
class Steps::Maint::RestartAllServers < Steps::Base

  step_info "(M1) Restart All Servers"

  class Options < HashModel
  end

  def execute!(step)
    machines = deployment.servers

    machines.each do |machine|
      machine.save_chef_node_information(true)
      machine.ssh do |ssh|
        ssh.exec!('sudo chef-client')
      end
    end
  end

  def finished?(step)
    true
  end

end
