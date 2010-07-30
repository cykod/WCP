
class Steps::Maint::RestartAllServers < Steps::Base

  step_info "(M2) Restart All Web and Workling Servers"

  parameter :restart_apache, :as => :boolean, :hint => 'Restart Apache as well?'

  class Options < HashModel
  end

  def execute!(step)
    machines = cloud.servers.select(&:active?)

    machines.each do |machine|

      machine.ssh do |ssh|
        cmd = 'cd /home/webiva/current '
        if machine.web_server?
          cmd += " && sudo -u webiva touch tmp/restart.txt"
        end

        if machine.workling_server?
          cmd += " && sudo -u webiva ./script/workling_client restart"
        end

        if deployment.blueprint_options.restart_apache.to_i == 1
          cmd += " && sudo apache2ctl restart"
        end

        puts "Server #{machine.ip_address} Restart: " + ssh.exec!(cmd).to_s
      end
    end
  end


end
