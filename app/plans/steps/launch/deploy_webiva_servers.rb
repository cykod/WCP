class Steps::Launch::DeployWebivaServers < Steps::Base

  step_info "(S6) Deploy the webiva code base", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    machine_list = deployment.servers


    client = ChefClient.new
    if step.substep == 0
      cloud.force_redeploy
      machine_list.each do |machine|
        log "Adding Webiva::Deploy recipe to #{machine.full_name}"
        client.add_to_run_list(machine,"recipe[webiva::deploy]")
      end
    else
      deployment.run_chef_client(machine_list) 
      cloud.unforce_redeploy
    end

  end

  def finished?(step)
    true
  end

end


