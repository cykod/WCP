
class Steps::Maint::RedeployServers < Steps::Base

  step_info "(R1) Rerun the deploy task and migrate" , :substeps => 2

  class Options < HashModel
  end

  def execute!(step)

    if step.substep == 0

    else
      machines = deployment.servers
      migrator = deployment.migrator

      deployment.cloud.force_redeploy


      rails_step("No migrator to redeploy") unless migrator

      # Force deploy
      # update the migrator
      # update system db, domain_dbs, domain_components
      client = ChefClient.new

      migrator.ssh do |ssh|
        puts client.exec_chef_client(ssh).to_s

        cmd = " cd /home/webiva/current "
        cmd += " && rake cms:migrate_system_db "
        cmd += " && rake cms:migrate_domain_dbs "
        cmd += " && rake cms:migrate_domain_components "

        puts ssh.exec!(cmd).to_s
      end

      machine_list = machines.select { |m| !m.migrator? }

      client.run_chef_client(machine_list) 

      deployment.cloud.unforce_redeploy
    end
  end

end
