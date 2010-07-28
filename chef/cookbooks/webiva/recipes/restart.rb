

execute 'workling_restart' do
  only_if { node['wcp']['restart'] && node['wcp']['roles'].include?('workling') }
  user 'webiva'
  group 'webiva'
  cwd "/home/webiva/current"
  command "script/workling_client restart; true"
end

execute 'webiva_restart' do 
 only_if { node['wcp']['restart'] && node['wcp']['roles'].include?('web') }
 user 'webiva'
 group 'webiva'
 cwd "/home/webiva/current"
 command "touch tmp/restart.txt"
end


node['wcp']['restart'] = false
