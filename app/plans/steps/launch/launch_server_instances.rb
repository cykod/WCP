class Steps::Launch::LaunchServerInstances < Steps::Base

  step_info "(S1) Launch Cloud Server Instances", :substeps => 2

  deployment_parameter(:app_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.ec2_select_options
                } })

  deployment_parameter :web_servers, :hint => 'Number of web servers to launch',:default => 1
  deployment_parameter :separate_aux_server, :as => :boolean, :hint => 'Launch a separate auxiliary server for Memcached, and starling'



  class Options < HashModel
    attributes :machine_ids => [ ]
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
        machine
      end

      step.options.machine_ids = machines.map(&:id)
    else
      step.options.machine_ids.each do |machine_id|
        machine = Machine.find(machine_id)
        begin
          machine.ssh do |ssh|
            puts ssh.exec!('uptime')
          end
        rescue Net::SSH::HostKeyMismatch => e
          puts "Remembering new key: #{e.fingerprint}"
          e.remember_host!
          retry
        end
      end
    end
  end

  def finished?(step)
    if step.substep == 0
      step.options.machine_ids.inject(true) do |state,machine_id|
        machine = Machine.find(machine_id)
        state = false if !machine.active?
        state
      end
    else
      true
    end
  end


  def machine_failed!(step,machine)
    machine = Machine.find(step.options.machine_id) 
    machine.terminate!
  end


  def machine_activated!(step,machine)
   #
  end
end
