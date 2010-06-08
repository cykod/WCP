


class Simple::LaunchFullInstance < Step


  class Options < HashModel
    attributes :machine_id => nil
  end


  def execute!(step)
    blueprint = MachineBlueprint.fetch(self.deployment.parameter(:app_machine_blueprint))
    machine = self.deployment.add_machine([:web,:memcached,:starling,:background,:updater],blueprint)

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
