


class Amazon::Ec2Machine 

  attr_reader :instance_id, :ec2

  def initialize(ec2,instance_id_or_hash)
    @ec2 = ec2

    puts(instance_id_or_hash.inspect)

    if instance_id_or_hash.is_a?(Hash)
      @internal_status = instance_id_or_hash
      @instance_id = internal_state['instanceId']
    else
      @instance_id = instance_id_or_hash
    end
  end

  def self.run_instances(ec2,opts={})
    Amazon::Ec2Machine.new(ec2,ec2.run_instances(opts))
  end


  def running?
    internal_state["instanceState"]["name"] == "running"
  end

  def failed?
    internal_state["instanceState"]["name"] == "failed"
  end

  def terminated?
    internal_state["instanceState"]["name"] == "terminated"
  end

  def terminate!
    @internal_status = nil
    @ec2.terminate_instances(:instance_id => @instance_id)
  end


  def internal_status
     @internal_status ||= @ec2.describe_instances(:instance_id => @instance_id)
  end


  def internal_state
    if internal_status['reservationSet']
      internal_status["reservationSet"]["item"][0]["instancesSet"]["item"][0]
    elsif internal_status['instancesSet']
      internal_status['instancesSet']['item'][0]
    end
  end
end
