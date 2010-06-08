

class LaunchMonitor < Monitor

  include SimplyStored::Couch

  belongs_to :machine

  property :active, :type => :boolean, :default => true

  def self.run_monitor!(machine)
    self.create(:machine => machine)
  end

  def monitor_cycle
    case self.machine.check_status 
    when 'active':
      self.machine.deployment.machine_activated!(self.machine)
      self.active = false
      self.save
    when 'failed':
      self.machine.deployment.machine_failed!(self.machine)
      self.active = false
      self.save
    end
  end


  def self.monitor_launches 
    LaunchMonitor.find_all_by_active(true).each do |monitor|
      monitor.monitor_cycle
    end
  end
end
