
class Steps::Launch::AssociateElasticIps < Steps::Base

  step_info "(S2) Associate Elastic Ips with each of the servers", :substeps => 1

  class Options < HashModel
    attributes :modified_machines => {}
  end

  def execute!(step)
    machines = deployment.servers

    already_allocated_instances = []

    # get a list of available ips
    ips = company.ec2.describe_addresses.map do |ip_info|
      if ip_info[:instance_id]
        already_allocated_instances << ip_info[:instance_id]
        nil
      else
        ip_info[:public_ip]
      end
    end.compact

    # Remove machines that already have an elastic IP
    machines = machines.reject { |m| already_allocated_instances.include?(m.instance_id) }

    # allocate any additional necessary IP addresses
    ips_to_allocate = machines.length - ips.length
    if ips_to_allocate > 0
      ips += (1..ips_to_allocate).map { company.ec2.allocate_address }
    end

    # Associate with addresses
    machines.each_with_index do |machine,idx|
      company.ec2.associate_address(machine.instance_id,ips[idx])
      step.config.modified_machines[machine.id] = ips[idx]
    end
  end

  def finished?(step)
     all_updated = true
     step.config.modified_machines.each do |machine_id,ip_adr|
       m = Machine.find(machine_id)

       m.hostname = nil # clear out the hostname so we update the machine info
       m.check_status!
       all_updated = false if m.ip_address != ip_adr
     end

     all_updated
  end

end
