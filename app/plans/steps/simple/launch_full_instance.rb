class Steps::Simple::LaunchFullInstance < Steps::Base

  step_info "Launch a full Webiva single Instance", :substeps => 2,  :options => "Steps::Simple::LaunchFullInstance::Options"

  parameter(:app_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.select_options
                } })

  deployment_parameter :roles

  class Options < HashModel
    attributes :machine_id => nil
  end


  def execute!(step)

    if step.substep == 0
      blueprint = MachineBlueprint.fetch(self.deployment.blueprint_options.app_machine_blueprint)

      fail_step("Missing Blueprint") unless blueprint
      machine = self.deployment.add_machine([:web,:memcache,:starling,:workling,:migrator,:cron],blueprint)
      machine.launch!

      step.options.machine_id = machine.id
    else
      machine = Machine.find(step.options.machine_id)
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

  def finished?(step)
     machine = Machine.find(step.options.machine_id) 
     machine.active?
  end


  def machine_failed!(step,machine)
    machine = Machine.find(step.options.machine_id) 
    machine.terminate!
  end


  def machine_activated!(step,machine)
   #
  end
end
