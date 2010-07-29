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

directory "/home/webiva/.ssh" do
  owner "webiva"
  group "webiva"
  mode "0700"
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
  mode "0777"
  action :create
end

directory "/home/webiva/shared/config/sites" do
  owner "webiva"
  group "webiva"
  mode "0775"
  action :create
end

template "/home/webiva/.ssh/config" do
  owner "webiva"
  group "webiva" 
  mode "0755"
  source "config.erb"
end

template "/etc/apache2/sites-available/default" do
  source "apache2_config_file.erb"
end

template "home/webiva/.ssh/id_rsa" do 
  owner "webiva"
  group "webiva"
  mode "0700"
  source "id_rsa.erb"
  variables({:gitkey => data_bag_item(node['wcp']['cloud'],"cloud")["gitkey"] })
end

deploy "/home/webiva" do
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
    cloud_data["gems"].each do |gem_name|
      if gem_name[1]
        gem_package gem_name[0] do
          version gem_name[1]
        end
      else
        gem_package gem_name[0]
      end
    end

    execute "buildgems" do
      cwd release_path
      command "rake gems:build"
      user "webiva"
      group "webiva"
    end

    cloud_data["module_list"].each do |md|
      execute "install_module_#{md[0]}" do 
        cwd release_path + "/vendor/modules"
        command "git clone #{md[1]} #{md[0]}; cd #{md[0]}; git checkout -b deploy #{md[2]}"
        user "webiva"
        group "webiva"
      end
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
