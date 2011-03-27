
class Machines::AwsAppServer < Machines::Base

  machine_info "AWS App Server", :instance_type => "ec2"

  parameter :instance_size, :as => :select, :collection => ['m1.small','m1.large','m1.xlarge','m2.xlarge','m2.2xlarge','m2.4xlarge','c1.medium','c1.xlarge', 'cc1.4xlarge' ],:required => true

  parameter :machine_image, :required => true
  parameter :root_user, :required => true

  def self.description(blueprint)
    "#{blueprint.config.instance_size} - #{blueprint.config.machine_image}"
  end

  def launch!
    instance = Amazon::Ec2Interface.run_instance(company.ec2,
                                      {  :key_name => company.key_name,
                                         :security_group => cloud.config.security_group,
                                         :instance_size => blueprint.config.instance_size,
                                         :availability_zone => cloud.config.availability_zone,
                                         :monitoring_enabled => true,
                                         :disable_api_termination => false,
                                         :image_id => blueprint.config.machine_image })

    machine.root_user = blueprint.config.root_user
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
    elsif ec2_machine.terminating?
       'terminating'
    elsif ec2_machine.terminated?
      'terminated'
      else
       'launched'
    end
  end

  protected

  def ec2_machine
    @ec2_machine ||=  Amazon::Ec2Interface.new(company.ec2,self.machine.instance_id)
  end
end

