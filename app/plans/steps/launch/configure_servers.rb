class Steps::Launch::ConfigureServers < Steps::Base

  step_info "(S4) Configure: add webiva_app_server role and deploy with chef", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    machine_list = deployment.servers

    client = ChefClient.new
    if step.substep == 0
      machine_list.each do |machine|
        client.add_to_run_list(machine,"role[webiva_app_server]")
      end
    else
      result = client.run_chef_client(machine_list) 
      puts "####" + result.to_s
    end
  end

  def finished?(step)
    true
  end

end


