

class LaunchMonitor < Monitor
  include Mongoid::Document
  include Mongoid::Timestamps


  belongs_to :machine

  field :active, :type => Boolean, :default => true

  def self.run_monitor!(machine)
    self.create(:machine => machine)
  end

  def monitor_cycle
    if !self.machine
      self.active = false
      self.save
      return
    end

    case self.machine.check_status! 
    when 'active':
      self.machine.deployment.machine_activated!(self.machine)
      self.active = false
      self.save
    when 'failed':
      self.machine.deployment.machine_failed!(self.machine)
      self.active = false
      self.save
    when 'terminated':
      self.active = false
      self.save
    end
  end


  def self.monitor_launches 
    LaunchMonitor.where(:action => true).each do |monitor|
      monitor.monitor_cycle
    end
  end
end
