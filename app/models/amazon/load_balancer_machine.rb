

class Amazon::LoadBalancerMachine 

  attr_reader :instance_id, :elb

 def initialize(elb,instance_id_or_hash)
    @elb = elb
    instance_id_or_hash = instance_id_or_hash[0] if instance_id_or_hash.is_a?(Array)
    if instance_id_or_hash.is_a?(Hash)
      @internal_status = instance_id_or_hash
      @instance_id = internal_state[:load_balancer_name]
    else
      @instance_id = instance_id_or_hash
    end
  end


 def self.create_balancer(elb,load_balancer_name,opts={})
   Amazon::LoadBalancerMachine.new(elb,
                         elb.create_load_balancer(
                                   load_balancer_name,
                                   [ opts[:availability_zone] ],
                                   [ { :protocol => :http, :load_balancer_port => 80,  :instance_port => 80 },
                                     { :protocol => :tcp,  :load_balancer_port => 443, :instance_port => 443 } ]))
 end

 def internal_state
   if !@internal_status
     info = nil
     info = @elb.describe_load_balancers(@instance_id) 
     if !info || !info[0]
       @internal_status = { :terminated => 'terminated' }
     else
       @internal_status = info[0] if info
     end
   else
     @internal_status
   end
 end


 def register_instances(instance_ids)
   @elb.register_instances_with_load_balancer(@instance_id,*instance_ids)
 end

 def deregister_instances(instance_ids)
   @elb.deregister_instances_with_load_balancer(@instance_id,instance_ids)
 end

 def running?; internal_state[:terminated] != 'terminated'; end
 def terminated?; internal_state[:terminated] == 'terminated'; end

 def hostname; internal_state[:dns_name]; end

 def terminate!
   @elb.delete_load_balancer(@internal_id)
 end

end
