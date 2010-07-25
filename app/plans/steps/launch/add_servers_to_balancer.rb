
class Steps::Launch::AddServersToBalancer < Steps::Base

  step_info "(S8) Add Deployment servers to the load balancer"

  class Options < HashModel
  end

  def execute!(step)
    balancer = cloud.load_balancer

    fail_step('Missing Load Balancer') unless balancer

    balancer_machine ||= Amazon::LoadBalancerMachine.new(company.elb,balancer.instance_id)

    machines = deployment.servers
    balancer_machine.register_instances(machines.map(&:instance_id))
  end

  def finished?(step)
    true
  end

end
