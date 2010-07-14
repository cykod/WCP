


class Steps::Simple::LaunchFullInstance < Steps::Base

  step_info "Launch a full Webiva single Instance", :substeps => 1,  :options => "Simple::LaunchFullInstance::Options"

  class Options < HashModel
    attributes :machine_id => nil
  end


  def execute!(step)
    blueprint = MachineBlueprint.fetch(self.deployment.parameter(:app_machine_blueprint))

    fail_step unless blueprint
    machine = self.deployment.add_machine([:web,:memcached,:starling,:background,:updater],blueprint)
    machine.launch!

    step.options.machine_id = machine.id
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
