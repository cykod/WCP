

class Steps::Terminate::TerminateMachines < Steps::Base

  step_info "(T4) Terminate deployment machines"

  class Options < HashModel

  end

  def execute!(step)
     machines = deployment.machines

     machines.each do |machine|
       machine.terminate!
     end
  end

  def finished?(step)
    deployment.machines.inject(true) do |ok,machine|
      ok = false if !machine.terminated?
      ok
    end
  end
end
