class Steps::Launch::AddScalingServers < Steps::Base

  step_info "(S1-Scale) Add additional servers to existing cloud", :substeps => 2

  deployment_parameter(:app_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.ec2_select_options
                } })

  deployment_parameter :web_servers, :hint => 'Number of web servers to launch',:default => 1
  deployment_parameter :server_types, :as => :radio, :collection => [['Both Workling and Web','both'],['Web only','web'],['Workling only','workling']]



  class Options < HashModel
    attributes :machine_ids => [ ]
  end


  def execute!(step)

    if step.substep == 0
      machine_blueprint = MachineBlueprint.fetch(deployment.deployment_options.app_machine_blueprint)

      fail_step("Missing Server Blueprint") unless machine_blueprint

      if deployment.deployment_options.server_types == 'both'
        role_base = [ :web,:workling ]
      elsif deployment.deployment_options.server_types == 'workling'
        role_base = [ :workling ]
      else
        role_base = [ :web ] 
      end

      server_roles = (1..deployment.deployment_options.web_servers.to_i).map { |i| role_base }
      machines = server_roles.map do |server_role_set|
        machine = self.deployment.add_machine(server_role_set,machine_blueprint)
        machine.launch!
        machine
      end

      step.config.machine_ids = machines.map(&:id)
    else
      step.config.machine_ids.each do |machine_id|
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
      step.config.machine_ids.inject(true) do |state,machine_id|
        machine = Machine.find(machine_id)
        state = false if !machine.active?
        state
      end
    else
      true
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
