


class Machines::LoadBalancer < Machines::Base

  machine_info "Elastic Load Balancer", :instance_type => 'balancer'


  def self.description(blueprint)
    "Load Balancer"
  end

  def launch!
    balancer_name =  'webiva-' + machine.id.to_s[0..16]
    instance = Amazon::LoadBalancerInterface.create_balancer(company.elb,
                                                           balancer_name,
                                                           :availability_zone => cloud.options.availability_zone)

    machine.instance_id = balancer_name
    machine.save
  end

  def check_status!
    if elb_machine.running?
      if machine.hostname.blank?
        machine.attributes = {
          :hostname => elb_machine.hostname
        }
      end
      'active'
    elsif elb_machine.terminated?
      'terminated'
    end
  end

  def terminate!
    elb_machine.terminate!
  end
  

  protected

  def elb_machine
    @dlb_machine ||= Amazon::LoadBalancerInterface.new(company.elb,self.machine.instance_id)
  end
end
