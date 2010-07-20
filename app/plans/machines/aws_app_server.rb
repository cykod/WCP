

class Machines::AwsAppServer < Machines::Base

  machine_info "Full AWS App Server", :instance_type => "ec2"

  def launch!
    instance = Amazon::Ec2Machine.run_instance(company.ec2,
                                      {  :key_name => company.key_name,
                                         :security_group => cloud.options.security_group,
                                         :instance_size => machine.instance_size,
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
      if machine.hostname.blank?
        machine.attributes = {
            :hostname => ec2_machine.hostname,
            :ip_address => ec2_machine.ip_address,
            :private_ip_address => ec2_machine.private_ip_address,
            :private_hostname => ec2_machine.private_hostname
        }
      end
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

