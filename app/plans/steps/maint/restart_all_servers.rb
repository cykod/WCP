
class Steps::Maint::RestartAllServers < Steps::Base

  step_info "(M2) Restart Web and Workling Servers"

  parameter :restart_apache, :as => :boolean, :hint => 'Restart Apache as well?'

  class Options < HashModel
  end

  def execute!(step)
    machines = deployment.servers

    machines.each do |machine|
      machine.ssh do |ssh|
        cmd = 'cd /home/webiva/current '
        if machine.web_server?
          cmd += " && sudo -u webiva touch tmp/restart.txt"
        end

        if machine.workling_server?
          cmd += " && sudo -i webiva ./script/workling_client restart"
        end

        if deployment.blueprint_options.restart_apache.to_i == 1
          cmd += " && sudo apache2ctl restart"
        end

        puts "Server #{machine.ip_address} Restart: " + ssh.exec!(cmd)
      end
    end
  end


end
