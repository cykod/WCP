

class AwsAppServer < MachineLauncher

  def launch!
    instance = Amazon::Ec2Machine.run_instances(company.ec2,
                                      {   :key_name => company.key_name,
                                         :security_group => cloud.options.security_group,
                                         :instance_type => machine.instance_type,
                                         :availability_zone => cloud.options.availability_zone,
                                         :monitoring_enabled => true,
                                         :disable_api_termination => false,
                                         :image_id => machine.machine_image })
    machine.instance_id = instance.instance_id
    machine.save

  end

  def terminate!
    ec2_machine.terminate!
  end

  def check_status!
    if ec2_machine.running?
      'active'
    elsif ec2_machine.failed?
       'failed'
    elsif ec2_machine.terminated?
      'terminated'
      else
       'launched'
    end
  end

  protected

  def ec2_machine
    @ec2_machine ||=  Amazon::Ec2Machine.new(company.ec2,self.machine.instance_id)
  end
end

