

class Steps::Simple::DestroyAllMachines < Steps::Base

  step_info "Terminate all machines"

  class Options < HashModel

  end

  def execute!(step)
    machines = self.deployment.cloud.machines

    active_machines = machines.select { |m| m.active? }
    active_machine_count = active_machines.length

    fail_step("No active machines") unless active_machine_count > 0

    active_machines.each do |machine|
      machine.terminate!
    end
  end

  def finished?(step)
    machines = self.deployment.cloud.machines
    machines.detect { |m| m.terminating? } ? false : true
  end

end
