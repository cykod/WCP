require_recipe "apache2"

remote_directory "/usr/local/build/mod_upload_progress" do
  source "mod_upload_progress"
end

execute "build and install mod_upload_progress" do
  command "cd /usr/local/build/mod_upload_progress && apxs2 -ci mod_upload_progress.c"
  not_if { File.exists?("/usr/lib/apache2/modules/mod_upload_progress.so") }
end

template "/etc/apache2/mods-available/upload_progress.load" do
  source 'upload_progress.load.erb'
end

apache_module "upload_progress"
