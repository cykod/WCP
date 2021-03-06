
class Steps::Launch::LaunchMasterRdsInstance < Steps::Base

  step_info "(D1) Launch the Master database instance", :substeps => 2

  deployment_parameter(:rds_machine_blueprint, Proc.new {  
                { :as => :select,
                  :collection => MachineBlueprint.rds_server_select_options
                } })

  deployment_parameter(:master_password)

  class Options < HashModel
    attributes :machine_id => nil
  end


  # Don't want to wait for these to boot,
  # So add two substeps, only check finished on the second one
  def execute!(step)

    if step.substep == 0
      machine_blueprint = MachineBlueprint.fetch(self.deployment.deployment_options.rds_machine_blueprint)

      fail_step("Missing RDS Machine Blueprint") unless machine_blueprint


      if !cloud.master_db
        machine = self.deployment.add_machine([:master_db],machine_blueprint)
        machine.launch!
        log "Launching new DB server from blueprint #{machine_blueprint.name}"
        step.config.machine_id = machine.id
      else
        step.config.machine_id = cloud.master_db.id
      end
    end
  end

  def finished?(step)
    if step.substep == 0
      # Noop - wait to check if active in the second step
      true
    else
      machine = Machine.find(step.config.machine_id) 
      if(machine.active?)
        log "RDS Service Activated"
        true
      end
    end
  end

  def machine_failed!(step,machine)
    machine = Machine.find(step.config.machine_id) 
    machine.terminate!
  end


  def machine_activated!(step,machine)
   #
  end
end
