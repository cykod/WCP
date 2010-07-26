


class Amazon::RdsInterface

  attr_reader :instance_id, :rds

  def initialize(rds,instance_id_or_hash)
    @rds = rds 
    instance_id_or_hash = instance_id_or_hash[0] if instance_id_or_hash.is_a?(Array)
    if instance_id_or_hash.is_a?(Hash)
      @internal_status = instance_id_or_hash
      @instance_id = internal_state[:aws_id]
    else
      @instance_id = instance_id_or_hash
    end
  end

  def self.run_instance(rds,aws_id,master_username,master_password,opts={})
    Amazon::RdsInterface.new(rds,
                           rds.create_db_instance(
                             aws_id,
                             master_username,
                             master_password,
                             opts))
  end

  def authorize_ip_address(security_group,ip_address)
    begin
      @rds.authorize_db_security_group_ingress(security_group,:cidrip => "#{ip_address}/32")
      return true
    rescue RightAws::AwsError => e
      return false
    end
  end

  def deauthorize_ip_address(security_group,ip_address)
    begin
      @rds.revoke_db_security_group_ingress(security_group,:cidrip => "#{ip_address}/32")
      return true
    rescue RightAws::AwsError => e
      return false
    end
  end

  def ip_address_authorization_complete?(security_group)
     auth_info = @rds.describe_db_security_groups(security_group)
     (auth_info[0][:ip_ranges]||[]).inject(true) do |state,elem|
       if elem[:status] != 'authorized'
         false
       else
         state
       end
     end
  end


  def internal_state
   if !@internal_status
     begin 
       info = @rds.describe_db_instances( @instance_id )
       @internal_status = info[0] if info
     rescue RightAws::AwsError
       @internal_status = { :status => 'deleted' }
     end
    else
      @internal_status
    end
  end

  def hostname
    internal_state[:endpoint_address]
  end

  def running?; internal_state[:status] == 'available';  end
  def failed?; internal_state[:status] == "failed";  end
  def terminated?; internal_state[:status] == "deleted";  end
  def terminating?; internal_state[:status] == "deleting"; end
  def launching?; internal_state[:status] == 'creating'; end

  def terminate!(skip_final = false)
    @internal_status = nil
    @rds.delete_db_instance( @instance_id, :skip_final_snapshot => skip_final )
  end

end
