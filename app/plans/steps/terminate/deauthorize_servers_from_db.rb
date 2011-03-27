

class Steps::Terminate::DeauthorizeServersFromDb < Steps::Base

  step_info "(T2) Remove Machines from the master database"

  class Options < HashModel
    
  end


  def execute!(step)
    db_machine = cloud.master_db

    if db_machine
      rds_machine = Amazon::RdsInterface.new(company.rds,db_machine.instance_id)
      machines = deployment.servers

      machines.each do |m|
        m.ssh do |ssh|
          ssh.exec!("cd /home/webiva/current; script/remove_server_info.rb")
        end
        rds_machine.deauthorize_ip_address(cloud.config.security_group,m.private_ip_address)
      end
    end
  end

end
