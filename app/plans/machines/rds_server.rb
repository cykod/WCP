

class Machines::RdsServer < Machines::Base

  machine_info "RDS Database Server", :instance_type => 'rds'

  parameter :instance_class, Proc.new { |deployment|
     { :as => 'select', :required => true,
       :collection =>  RightAws::RdsInterface::INSTANCE_CLASSES
     }
  }

  parameter :instance_storage, :hint => 'Gigabytes of storage, defaults to 5', :required => true


  def self.description(blueprint)
    "#{blueprint.options.instance_class} - #{blueprint.options.instance_storage||5}GB"
  end

  def launch!
    machine.initialize_rds_options

    instance = Amazon::RdsMachine.run_instance(
                   company.rds,
                   'webiva-' + machine.id,
                   machine.master_username,
                   machine.master_password,
                   {
                      :instance_size => machine.instance_size,
                      :db_security_groups => [ cloud.options.security_group ],
                      :availability_zone => cloud.options.availability_zone,
                      :allocated_storage => (blueprint.options.instance_storage || 5).to_i
                    })
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


  protected

  def rds_machine
    @rds_machine ||= Amazon::RdsMachine.new(company.rds,self.machine.instance_id)
  end
end
