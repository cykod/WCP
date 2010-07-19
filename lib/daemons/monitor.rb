
puts '=> Loading Rails...'


require File.dirname(__FILE__) + '/../../config/environment'

puts "=> Loaded, running monitor"

$running = true
Signal.trap("TERM") do
  $running = false
end


while($running) do
  begin
    DeploymentMonitor.monitor_deployments
  rescue Exception => e
    Rails.logger.error "Monitor Error: #{e.to_s}"
  end

  begin
    LaunchMonitor.monitor_launches
  rescue Exception => e
    Rails.logger.error "Launch Monitor Error: #{e.to_s}"
  end

  sleep 10 
end
