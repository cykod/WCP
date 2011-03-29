class Steps::Launch::LaunchServerInstances < Steps::Base

  step_info "(S1) Launch Cloud Server Instances", :substeps => 2

  deployment_parameter(:app_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.ec2_select_options
                } })

  deployment_parameter :web_servers, :hint => 'Number of web servers to launch',:default => 1
  deployment_parameter :separate_aux_server, :as => :boolean, :hint => 'Launch a separate auxiliary server for Memcached, and starling'



  class Options < HashModel
    attributes :machine_ids => [ ], :activated_machines => {}, :sshed_machines => {}
  end


  def execute!(step)

    if step.substep == 0
      machine_blueprint = MachineBlueprint.fetch(deployment.deployment_options.app_machine_blueprint)

      fail_step("Missing Server Blueprint") unless machine_blueprint

      server_roles = (1..deployment.deployment_options.web_servers.to_i).map { |i| [ :web,:workling ] }

      if !deployment.deployment_options.separate_aux_server.to_i == 1 
         server_roles << [ :memcache, :starling, :migrator, :cron ]
      else
         server_roles[0] +=  [ :memcache, :starling, :migrator, :cron ]
      end

      machines = server_roles.map do |server_role_set|
        machine = self.deployment.add_machine(server_role_set,machine_blueprint)
        machine.launch!
        log("Launching Machine #{machine.full_name} with roles [#{server_role_set.join(", ") }]")
        machine
      end

      step.config.machine_ids = machines.map(&:id).map(&:to_s)
    end
  end

  def finished?(step)
    if step.substep == 0
      step.config.machine_ids.inject(true) do |state,machine_id|
        machine = Machine.find(machine_id)
        if(machine.active? && !step.config.activated_machines[machine_id]) 
          log("Machine Activated: #{machine.full_name}")
          step.config.activated_machines[machine_id] = true
        end
        state = false if !machine.active?
        state
      end
    else
      step.config.machine_ids.each do |machine_id|
        machine = Machine.find(machine_id)
        begin
          machine.ssh do |ssh|
            puts ssh.exec!('uptime')
          end
          if(machine.active? && !step.config.sshed_machines[machine.id.to_s]) 
            log("SSH'd in successfully to: #{machine.full_name}")
            step.config.sshed_machines[machine.id.to_s] = true
          end
        rescue Net::SSH::HostKeyMismatch => e
          log "KeyMismatch Remembering new key: #{e.fingerprint}"
          e.remember_host!
          retry
        rescue Exception => e
          log("Exception SSHing to machine #{machine.name}: #{e.to_s} (Don't worry, this just takes a second)")
          return false
        end
      end
      return true
    end
  end


  def machine_failed!(step,machine)
    machine = Machine.find(step.config.machine_id) 
    machine.terminate!
  end


  def machine_activated!(step,machine)
   #
  end
end
