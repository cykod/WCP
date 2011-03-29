

class Steps::Terminate::TerminateMachines < Steps::Base

  step_info "(T4) Terminate deployment machines"

  class Options < HashModel
    attributes :terminated_machines  => {}

  end

  def execute!(step)
    machines = deployment.machines
    log("Running terminate on [#{machines.map(&:full_name).join(',')}]")

    machines.each do |machine|
      log("Terminating machine: #{machine.full_name}")
      machine.terminate!
    end
  end

  def finished?(step)
    deployment.machines.inject(true) do |ok,machine|
      ok = false if !machine.terminated?
      if(machine.terminated? && !step.config.terminated_machines[machine.id.to_s])
        log("Machine Terminated: #{machine.full_name}")
        step.config.terminated_machines[machine.id.to_s] = true
      end
      ok
    end
  end
end
