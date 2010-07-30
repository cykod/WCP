



class Steps::Maint::SnapshotMasterServer < Steps::Base

  step_info "(DM1) Take a snapshot of the Master DB Server"


  deployment_parameter :snapshot_name

  class Options < HashModel
  end

  def execute!(step)
    db_server = cloud.master_db

    
    rds = db_server.launcher.rds_machine
    rds.snapshot(deployment.deployment_options.snapshot_name)
  end


end
