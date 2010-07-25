
class Steps::Launch::AuthorizeServersToDb < Steps::Base

  step_info "(S6) Authorize servers on the master database", :substeps => 2

  class Options < HashModel
  end

  def execute!(step)
    db_machine = cloud.master_db

    fail_step('Missing Master Database') unless db_machine
 
    rds_machine = Amazon::RdsMachine.new(company.rds,db_machine.instance_id)
    machines = deployment.servers

    machines.each do |m|
      rds_machine.authorize_ip_address(cloud.options.security_group,m.private_ip_address)
    end
  end

  def finished?(step)
    db_machine = cloud.master_db
    rds_machine = Amazon::RdsMachine.new(company.rds,db_machine.instance_id)
    rds_machine.ip_address_authorization_complete?(cloud.options.security_group)
  end

end
