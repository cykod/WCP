

class Steps::Terminate::RemoveFromLoadBalancer < Steps::Base

  step_info "(T1) Remove Machines from the load balancer"

  class Options < HashModel
    
  end

  def execute!(step)
    balancer = cloud.load_balancer

    fail_step("Missing Load Balancer") unless balancer

    balancer_machine = Amazon::LoadBalancerInterface.new(company.elb,balancer.instance_id)

    servers = deployment.web_servers
    balancer_machine.deregister_instances(servers.map(&:instance_id))
  end


end
