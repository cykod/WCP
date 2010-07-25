class Steps::Launch::BootstrapChef < Steps::Base

  step_info "(S3) Bootstrap any launched servers with Chef", :substeps => 1

  class Options < HashModel

  end


  def execute!(step)
    server_list = self.deployment.servers

    fail_step("No servers") unless server_list.length > 0 


    server_list.each do |server|
      sftp = server.ssh.sftp

      sftp.mkdir!("chef")

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
    "server_url": "#{Server.external_server_url}"
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

      sftp.upload!(Server.validation_pem_file,'validation.pem')
    end

    session = Net::SSH::Multi.start 

    server_list.each do |server|
      server.multi_ssh(session)
    end

    # Boot strap, but then don't run chef-client automatically
    cmd = 'sudo apt-get update'
    cmd += ' && sudo apt-get --yes install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc build-essential wget rubygems'
    cmd += ' && sudo gem install chef --no-rdoc --no-ri'
    
    cmd += " && sudo /var/lib/gems/1.8/bin/chef-solo -c ~/chef/solo.rb -j ~/chef/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
    cmd += ' && sudo mv environment /etc/'
    cmd += ' && echo "alias sudo=\'sudo env PATH=\\$PATH\'" >> ~/.bashrc'
    cmd += ' && sudo mv validation.pem /etc/chef/'
    cmd += ' && sudo /etc/init.d/chef-client stop'
    cmd += ' && sudo /var/lib/gems/1.8/bin/chef-client'
    cmd += ' && sudo rm /etc/chef/validation.pem'
    session.exec(cmd)
    session.loop
    session.close 

    server_list.each do |server|
      server.state_data['chef_bootstrapped'] = true
      server.save

      server.save_chef_node_information
    end



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
