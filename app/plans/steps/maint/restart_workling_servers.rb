
class Steps::Maint::RestartWorklingServers < Steps::Base

  step_info "(M2) Restart All Workling Servers in cloud"

  class Options < HashModel
  end

  def execute!(step)
    machines = cloud.servers.select(&:active?).select(&:workling_server?)

    session = Net::SSH::Multi.start 

    machines.each do |server|
      server.multi_ssh(session)
    end

    cmd = 'cd /home/webiva/current '
    cmd += " && sudo -u webiva ./script/workling_client stop"
    cmd += " && sudo -u webiva ./script/workling_client start"
    session.exec(cmd)
    session.loop
    session.close 
  end

end
