
class Steps::Launch::LaunchLoadBalancer < Steps::Base

  step_info "(B1) Launch a load balancer", :substeps => 2 

  parameter(:balancer_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.elb_select_options
                } })

  class Options < HashModel
    attributes :machine_id => nil
  end


  def execute!(step)

    if step.substep == 0
      machine_blueprint = MachineBlueprint.fetch(blueprint.blueprint_options.balancer_machine_blueprint)

      fail_step("Missing Load Balancer Machine") unless machine_blueprint

      fail_step('Existing Load balancer') if cloud.load_balancer

      machine = self.deployment.add_machine([:balancer],machine_blueprint)
      machine.launch!

      step.options.machine_id = machine.id
    else
      machine = Machine.find(step.options.machine_id)
      load_balancer = Amazon::LoadBalancerInterface.new(company.elb,machine.instance_id)
      load_balancer.configure_health_check( { :healthy_threshold => 5,
                                              :unhealthy_threshold => 2,
                                              :target => "TCP:80",
                                              :timeout => 10,
                                              :interval => 31})
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
