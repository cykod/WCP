
class Steps::Maint::QuickRedeployServers < Steps::Base

  step_info "(R1-Quick) Rerun the deploy task (No migration)" , :substeps => 2 

  class Options < HashModel
  end

  def execute!(step)

    if step.substep == 0

    else
      machines = deployment.servers
      deployment.cloud.force_redeploy

      log "Quick Redeploy"
      deployment.run_chef_client(machines) 

      deployment.cloud.unforce_redeploy
    end
  end

end
