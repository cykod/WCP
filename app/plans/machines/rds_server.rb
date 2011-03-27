

class Machines::RdsServer < Machines::RdsServerSnapshot 

  machine_info "RDS Database Server", :instance_type => 'rds'

  parameter :instance_class, Proc.new { |deployment|
     { :as => 'select', :required => true,
       :collection =>  RightAws::RdsInterface::INSTANCE_CLASSES
     }
  }

  parameter :instance_storage, :hint => 'Gigabytes of storage, defaults to 5', :required => true


  def self.description(blueprint)
    "#{blueprint.config.instance_class} - #{blueprint.config.instance_storage||5}GB"
  end

  def launch!
    machine.initialize_rds_options(machine.deployment.deployment_options.master_password)

    instance = Amazon::RdsInterface.run_instance(
                   company.rds,
                   'webiva-' + machine.id,
                   machine.master_username,
                   machine.master_password,
                   {
                      :instance_size => machine.instance_size,
                      :db_security_groups => [ cloud.config.security_group ],
                      :availability_zone => cloud.config.availability_zone,
                      :allocated_storage => (blueprint.config.instance_storage || 5).to_i
                    })
    machine.instance_id = instance.instance_id
    machine.save
  end

 end
