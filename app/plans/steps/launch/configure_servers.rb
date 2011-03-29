class Steps::Launch::ConfigureServers < Steps::Base

  step_info "(S5) Configure: add webiva_app_server role and deploy with chef", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    machine_list = deployment.servers

    client = ChefClient.new
    if step.substep == 0
      machine_list.each do |machine|
        log "Adding webiva_app_server role to #{machine.full_name}"
        client.add_to_run_list(machine,"role[webiva_app_server]")
      end
    else
      log "Running Check client"
      deployment.run_chef_client(machine_list) 
    end
  end

  def finished?(step)
    true
  end

end


