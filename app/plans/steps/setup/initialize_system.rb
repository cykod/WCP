

class Steps::Setup::InitializeSystem < Steps::Base

  step_info "(I2) Initialize Webiva Install"

  deployment_parameter :client_name, :hint => 'No spaces'
  deployment_parameter :admin_username, :hint => 'No Spaces'
  deployment_parameter :admin_password, :hint => 'No Spaces'
  deployment_parameter :initial_domain, :hint => 'No Spaces'

  class Options < HashModel

  end

  def execute!(step)
     machine = cloud.migrator
     ssh = machine.ssh

     opts = deployment.deployment_options

     cmd =  " cd current "
     cmd =  " && rake cms:migrate_system_db"
     cmd += " && rake cms:initialize_system CLIENT='#{opts.client_name}' DOMAIN='#{opts.initial_domain}' USERNAME='#{opts.admin_username}' ADMIN_PASSWORD='#{opts.admin_password}'"
     cmd += " && rake cms:create_domain_db DOMAIN_ID=1"

     ssh.exec!(cmd)
     ssh.close
  end


  def finished?(step)
    true
  end
end
