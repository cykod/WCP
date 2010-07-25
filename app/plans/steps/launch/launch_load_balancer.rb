
class Steps::Launch::LaunchLoadBalancer < Steps::Base

  step_info "(B1) Launch a load balancer", :substeps => 1

  parameter(:balancer_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.elb_select_options
                } })

  class Options < HashModel
    attributes :machine_id => nil
  end


  def execute!(step)
    machine_blueprint = MachineBlueprint.fetch(blueprint.blueprint_options.balancer_machine_blueprint)

    fail_step("Missing Load Balancer Machine") unless machine_blueprint

    fail_step('Existing Load balancer') if cloud.load_balancer

    machine = self.deployment.add_machine([:balancer],machine_blueprint)
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
