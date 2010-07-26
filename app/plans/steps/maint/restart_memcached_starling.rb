
class Steps::Maint::RestartMemcachedStarling < Steps::Base

  step_info "(M1) Restart Memcached and Queue servers" 

  class Options < HashModel
  end

  def execute!(step)
    machines = deployment.servers

    machines.each do |machine|
      if machine.starling? || machine.memcache? 
        machine.ssh do |ssh|
          cmd = 'cd /home/webiva/current '

          if machine.starling?
            cmd += " && sudo -u webiva env PATH=$PATH ./script/kill_starling.rb "
            cmd += " && sudo -u webiva env PATH=$PATH ./script/starling.rb "
          end

          if machine.memcache?
            cmd += " && sudo /etc/init.d/memcached restart"
          end

          ssh.exec!(cmd)

          puts "Server #{machine.ip_address} Queue/Memcache Restart: " + ssh.exec!(cmd)
        end
      end
    end
  end

end
