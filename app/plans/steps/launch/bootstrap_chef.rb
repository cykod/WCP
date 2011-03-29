class Steps::Launch::BootstrapChef < Steps::Base

  step_info "(S3) Bootstrap any launched servers with Chef", :substeps => 1

  class Options < HashModel

  end


  def execute!(step)
    server_list = self.deployment.servers

    fail_step("No servers") unless server_list.length > 0 

    server_list.each do |machine|
      begin
        machine.ssh do |ssh|
          puts ssh.exec!('uptime')
        end
      rescue Net::SSH::HostKeyMismatch => e
        puts "Remembering new key: #{e.fingerprint}"
        e.remember_host!
        retry
      end
      log("Chef bootstrapping Machine #{machine.full_name}")
    end

    server_list.each do |server|
      sftp = server.ssh.sftp

      sftp.mkdir!("chef") rescue Net::SFTP::StatusException

      sftp.file.open('chef/solo.rb','w') do |f|
        f.puts(<<-EOF)
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
        EOF
      end

      sftp.file.open('chef/chef.json','w') do |f|
        f.puts(<<-EOF)
{
  "chef": {
    "server_url": "#{Server.external_server_url}",
    "validation_client_name": "#{Server.authorized_client_user}"
  },
  "run_list": [ "recipe[chef::bootstrap_client]" ]
}
        EOF

      end

      sftp.file.open('environment', 'w') do |f|
        f.puts(<<-EOF)
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/var/lib/gems/1.8/bin"
        EOF
      end

      sftp.upload!(Server.authorized_client_pem_file,'validation.pem')
    end

   
#    cmd += ' && echo "alias sudo=\'sudo env PATH=\\$PATH\'" >> ~/.bashrc'
    # Boot strap, but then don't run chef-client automatically
    cmd = <<-EOF
    sudo apt-get update 
    && sudo apt-get --yes install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc build-essential wget rubygems \
    && sudo gem install chef --no-rdoc --no-ri \
    && sudo /var/lib/gems/1.8/bin/chef-solo -c ~/chef/solo.rb -j ~/chef/chef.json -r http://s3.amazonaws.com/webiva/chef-bootstrap-webiva.tar.gz \
    && sudo mv environment /etc/ \
    && sudo mv validation.pem /etc/chef/ \
    && sudo /etc/init.d/chef-client stop \
    && sudo /var/lib/gems/1.8/bin/chef-client \
    && sudo rm /etc/chef/validation.pem 
    EOF

    log("Bootstrapping")

    deployment.multi_ssh(server_list,cmd)
    
 
    log("Bootstrapping Complete - registering nodes")
    server_list.each do |server|
      server.state_data['chef_bootstrapped'] = true
      server.save
      server.save_chef_node_information
    end
    log("Nodes Registered - all done!")
  end

  def finished?(step)
    server_list = self.deployment.servers

    if server_list.detect { |s| !s.state_data['chef_bootstrapped'] }
      false
    else
      true
    end
  end


end
