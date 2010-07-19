


class DeploymentMonitor < Monitor

  include SimplyStored::Couch

  belongs_to :deployment

  property :active_step, :type => Fixnum
  property :active, :type => :boolean, :default => true

  def self.run_monitor!(deployment,step)
    self.create(:deployment => deployment, :active_step => step)
  end

  def monitor_cycle
    Rails.logger.info "Monitoring Deployment: #{self.deployment.name}"
    if self.deployment.finished?
      Rails.logger.info "Deployment Finished: #{self.deployment.name}"
      self.deployment.finish!
      self.active = false
      self.save
    elsif self.deployment.failed?
      self.active = false
      self.save
    elsif self.deployment.step_finished?(self.active_step)
      self.active_step = self.active_step + 1
      Rails.logger.info "---- Step:#{self.active_step} "
       self.deployment.finish!

      if self.save
        if !self.deployment.execute_step!(self.active_step)
          self.active = false
          self.save
        end
      end
    end
    self.reload
  end


  def self.monitor_deployments
    DeploymentMonitor.find_all_by_active(true).each do |monitor|
      monitor.monitor_cycle
    end
  end
end
