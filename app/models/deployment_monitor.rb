


class DeploymentMonitor < Monitor

  include SimplyStored::Couch

  belongs_to :deployment

  property :active_step, :type => Fixnum
  property :active, :type => :boolean, :default => true

  def self.run_monitor!(deployment,step)
    self.create(:deployment => deployment, :active_step => step)
  end

  def monitor_cycle
    if self.deployment.step_finished?(self.active_step)
      self.active_step = self.active_step + 1
      if self.save
        if !self.deployment.execute_step!(self.active_step)
          self.active = false
          self.save
        end
      end
    end
  end


  def self.monitor_deployments
    DeploymentMonitor.find_all_by_active(true).each do |monitor|
      monitor.monitor_cycle
    end
  end
end
