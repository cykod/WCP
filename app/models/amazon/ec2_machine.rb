


class Amazon::Ec2Machine 

  attr_reader :instance_id, :ec2

  def initialize(ec2,instance_id_or_hash)
    @ec2 = ec2
    instance_id_or_hash = instance_id_or_hash[0] if instance_id_or_hash.is_a?(Array)
    if instance_id_or_hash.is_a?(Hash)
      @internal_status = instance_id_or_hash
      @instance_id = internal_state[:aws_instance_id]
    else
      @instance_id = instance_id_or_hash
    end
  end

  def self.run_instance(ec2,opts={})
    Amazon::Ec2Machine.new(ec2,
                           ec2.run_instances(
                             opts[:image_id],
                             1,
                             1,
                             [ opts[:security_group] ],
                             opts[:key_name],
                             opts[:user_data] || '',
                             'public', # addressing type
                             opts[:instance_size],
                             nil, # Kernel
                             nil, # Ramdisk
                             opts[:availability_zone]))
  end

  def internal_state
    if !@internal_status
      info = @ec2.describe_instances([ @instance_id ])
      if !info || !info[0]
         @internal_status = { :aws_state => 'terminated' }
      else
        @internal_status = info[0] if info
      end
    else
      @internal_status
    end
  end

  def hostname; internal_state[:dns_name]; end
  def ip_address; internal_state[:ip_address]; end
  def private_hostname; internal_state[:private_dns_name]; end
  def private_ip_address; internal_state[:private_ip_address]; end


  def running?
    internal_state[:aws_state] == 'running'
  end

  def failed?
    internal_state[:aws_state] == "failed"
  end

  def terminating?
    internal_state[:aws_state] == 'terminating'
  end

  def terminated?
    internal_state[:aws_state] == "terminated"
  end

  def terminate!
    @internal_status = nil
    @ec2.terminate_instances([ @instance_id ])
  end

end
