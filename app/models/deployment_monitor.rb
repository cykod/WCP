


class DeploymentMonitor < Monitor

  include SimplyStored::Couch

  belongs_to :deployment

  property :active_step, :type => Fixnum
  property :active, :type => :boolean, :default => true

  view :by_active, :key => :active

  def self.run_monitor!(deployment,step)
    self.create(:deployment => deployment, :active_step => step)
  end

  def monitor_cycle
    if !self.deployment
      self.active = false
      self.save
      return false
    end

    Rails.logger.info "Monitoring Deployment: #{self.deployment.name} - #{self.deployment.active_step_name}"
    if self.deployment.finished?
      Rails.logger.info "Deployment Finished: #{self.deployment.name}"
      self.deployment.finish!
      self.deployment.cloud.update_active_state!
      self.active = false
      self.save
    elsif self.deployment.failed?
      self.active = false
      self.save
    else
      Rails.logger.info "--- Checking if step finished #{self.active_step}"
      if self.deployment.step_finished?(self.active_step)
        Rails.logger.info "---- Step Finished:#{self.active_step} "
        self.active_step = self.active_step + 1
        if self.save
          Rails.logger.info "---- Executing step #{self.active_step}"
          if !self.deployment.execute_step!(self.active_step)
            self.active = false
            self.save
          end
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
