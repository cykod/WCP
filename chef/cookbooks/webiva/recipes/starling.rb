
execute 'starling_restart' do 
  only_if do 
    (node['wcp']['starling_restart'] && node['wcp']['roles'].include?('starling'))
  end
  notifies :restart, resources(:service => "apache2")
  user 'webiva'
  group 'webiva'
  cwd "/home/webiva/current"
  command "script/kill_starling.rb; script/starling.rb"
end

node['wcp']['starling_restart'] = false

