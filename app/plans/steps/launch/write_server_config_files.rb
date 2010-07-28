

class Steps::Launch::WriteServerConfigFiles < Steps::Base

  step_info "(S7) Write server configuration files", :substeps => 2

  class Options < HashModel

  end

  def execute!(step)
    
    servers = deployment.servers

    fail_step("No servers") unless servers.length > 0

    if step.substep == 0
      # need to write cms.yml, cms_migrator.yml, defaults.yml, workling.yml

      queue_servers = cloud.queue_servers
      memcache_servers = cloud.memcache_servers
      master_db = cloud.master_db

      workling_yaml_data = {
        'production' => { 'listens_on' => queue_servers.map { |s| "#{s.private_hostname}:15151" }.join(", ") },
        'development' => { 'listens_on' => queue_servers.map { |s| "#{s.private_hostname}:22122" }.join(", ") }
      }

      defaults_yaml_data = {
        'default_language' => 'en',
        'default_country' => 'US',
        'active_cache' => true,
        'use_x_send_file' => true,
        'enable_beta_code' => true,
        'system_admin' => 'pascal@cykod.com',
        'memcache_servers' => memcache_servers.map { |s| "#{s.private_hostname}:11211" }
      }

      db_config = {
        'encoding' => 'utf8',
        'adapter' => 'mysql',
        'database' => 'webiva',
        'host' => master_db.hostname,
        'socket' => '/var/run/mysqld/mysqld.sock',
        'pool' => 12
      }

      cms_yaml_data = {
        'production' => db_config.merge('username' => cloud.config.db_user,
                                        'password' => cloud.config.db_user_password),

                                        'development' => db_config.merge('username' => cloud.config.db_user,
                                                                         'password' => cloud.config.db_user_password)
      }

      cms_migrator_yaml_data = {
        'production' => db_config.merge('username' => cloud.config.migrator_user,
                                        'password' => cloud.config.migrator_user_password),

                                        'development' => db_config.merge('username' => cloud.config.migrator_user,
                                                                         'password' => cloud.config.migrator_user_password)

      }

      servers.each do |server|
        ssh = server.ssh
        sftp = ssh.sftp 

        ssh.exec!('sudo chmod -R a+w /home/webiva/shared/config/')

        sftp.file.open("/home/webiva/shared/config/workling.yml","w") do |f|
          f.puts(YAML.dump(workling_yaml_data))
        end

        sftp.file.open("/home/webiva/shared/config/defaults.yml","w") do |f|
          f.puts(YAML.dump(defaults_yaml_data.merge(
            'starling' => "#{server.private_hostname}:15151"
          )))
        end

        sftp.file.open("/home/webiva/shared/config/cms.yml","w") do |f|
          f.puts(YAML.dump(cms_yaml_data))
        end

        sftp.file.open('/home/webiva/shared/config/cms_migrator.yml','w') do |f|
          f.puts(YAML.dump(cms_migrator_yaml_data))
        end

        sftp.file.open('/home/webiva/shared/config/server.yml','w') do |f|
          f.puts(YAML.dump({ 'server' => { 'name' => server.private_hostname,
                           'type' => 'slave',
                           'roles' => server.roles } }))

        end

        ssh.close

      end
    else
      servers = deployment.servers

      fail_step("No servers") unless servers.length > 0
      servers.each do |server|
        server.ssh do |ssh|
          ssh.exec!("cd /home/webiva/current; sudo -u webiva ./script/update_server_info.rb")
        end
      end

    end

  end

end
