# 
#
#
#
#
#

gem_package "starling"
gem_package "daemons"

link "/home/webiva" do
  to "/mnt/webiva"
end

group "webiva" do
 members ['ubuntu']
end

user "webiva" do
  comment "Main Webiva User"
  gid "webiva"
  shell "/bin/bash"
  home "/home/webiva"
end

directory "/mnt/webiva" do
  owner 'webiva'
  group 'webiva'
end

directory "/home/webiva" do
  owner "webiva"
  group "webiva"
  mode "0755"
  action :create
end

directory "/home/webiva/shared" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end
directory "/home/webiva/shared/config" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end


directory "/home/webiva/shared/log" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end


directory "/home/webiva/shared/pids" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end

directory "/home/webiva/shared/system" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end

directory "/home/webiva/shared/config/sites" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end

template "/etc/apache2/sites-available/default" do
  source "apache2_config_file.erb"
end

deploy_revision "/home/webiva" do
  cloud_data = data_bag_item(node['wcp']['cloud'],"cloud")
  if cloud_data['redeploy']
    action :force_deploy
  end
  repo cloud_data["repository"].to_s == "" ? "git://github.com/cykod/Webiva.git" : cloud_data['repository']
  revision cloud_data["branch"]
  user "webiva"
  group "webiva"
  migration_command "echo true"
  migrate true

  purge_before_symlink [ "log","tmp/pids","public/system","config/sites" ]

  symlink_before_migrate "config/cms.yml" => "config/cms.yml",
                         "config/cms_migrator.yml" => "config/cms_migrator.yml",
                         "config/defaults.yml" => "config/defaults.yml",
                         "config/workling.yml" => "config/workling.yml",
                         "config/server.yml" => "config/server.yml",
                         "config/sites" => "config/sites"

  before_migrate do
    # Get rid of the sites directory in the way

    file "/home/webiva/shared/config/server.yml"  
    file "/home/webiva/shared/config/cms.yml"
    file "/home/webiva/shared/config/defaults.yml"
    file "/home/webiva/shared/config/workling.yml"
    file "/home/webiva/shared/config/cms_migrator.yml"
  end

  
  before_symlink do
    execute "buildgems" do
      cwd release_path
      command "rake gems:build"
      user "webiva"
      group "webiva"
    end
  end



  restart do
    current_release = release_path
    file "#{release_path}/tmp/restart.txt" do
      action 'touch'
      mode "0644"
      owner 'webiva'
      group 'webiva'
    end
  end
end
