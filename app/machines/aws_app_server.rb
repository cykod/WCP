

class AwsAppServer < MachineLauncher

  def launch!
    instance = company.ec2.run_instances(:key_name => company.key_name,
                                         :security_group => cloud.options.security_group,
                                         :instance_type => machine.instance_type,
                                         :availability_zone => cloud.options.availability_zone,
                                         :monitoring_enabled => true,
                                         :disable_api_termination => false,
                                         :image_id => machine.machine_id)

    instance.symbolize_keys!
    machine.instance_id = instance[:instance_id]
    machine.save

  end


  def terminate!
    company.ec2.terminate_instances(:instance_id => self.machine.instance_id)
  end

  def check_status!
    company.ec2.describe_instances(:instance_id => self.machine.instance_id)
  end
end

