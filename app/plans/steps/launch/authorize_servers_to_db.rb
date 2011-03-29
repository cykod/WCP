
class Steps::Launch::AuthorizeServersToDb < Steps::Base

  step_info "(S4) Authorize servers on the master database", :substeps => 2

  class Options < HashModel
  end

  def execute!(step)
    db_machine = cloud.master_db

    fail_step('Missing Master Database') unless db_machine
 
    rds_machine = Amazon::RdsInterface.new(company.rds,db_machine.instance_id)
    machines = deployment.servers

    machines.each do |m|
      log "Authorizing #{m.full_name} onto master db server #{db.full_name}"
      rds_machine.authorize_ip_address(cloud.config.security_group,m.private_ip_address)
    end
  end

  def finished?(step)
    db_machine = cloud.master_db
    rds_machine = Amazon::RdsInterface.new(company.rds,db_machine.instance_id)
    if(rds_machine.ip_address_authorization_complete?(cloud.config.security_group))
      log "IP Authorization complete"
      true
    end
  end

end
