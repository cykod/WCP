

class Machines::RdsServerSnapshot < Machines::Base
  # WebivaIsN1gogo
  machine_info "RDS Database Server - restore from Snapshot", :instance_type => 'rds'

  def self.description(blueprint)
    "Restored RDS Snapshot"
  end

  def launch!

    instance = Amazon::RdsInterface.restore_instance(
                   company.rds,
                   'webiva-' + machine.id,
                   machine.deployment.deployment_options.snapshot_name,
                   {
                      :db_security_groups => [ cloud.options.security_group ],
                      :availability_zone => cloud.options.availability_zone,
                    })
    machine.initialize_rds_options(machine.deployment.deployment_options.master_password,instance.master_username)
    machine.instance_id = instance.instance_id
    machine.save
  end

  def check_status!
    if rds_machine.running?
      if machine.hostname.blank?
        machine.attributes= {
            :hostname => rds_machine.hostname
        }
      end
      "active"
    elsif rds_machine.failed?
     "failed"
    elsif rds_machine.terminating?
      "terminating"
    elsif rds_machine.terminated?
      "terminated"
    elsif rds_machine.launching?
      "launched"
    else
      "unknown"
    end
  end

  def terminate!
    rds_machine.terminate!
  end


  def rds_machine
    @rds_machine ||= Amazon::RdsInterface.new(company.rds,self.machine.instance_id)
  end
end
