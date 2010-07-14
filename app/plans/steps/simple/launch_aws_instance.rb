


class Steps::Simple::LaunchAwsInstance < Steps::Base

  step_info "Launch an AWS Instance", :substeps => 4

  class Options < HashModel
    attributes :monitor_call_num => 0 
  end


  def execute!(step)
    puts "Executing Fake instance step substep ##{step.substep}"
    step.options.monitor_call_num = 0
  end

  def finished?(step)
     puts "Monitoring substep ##{step.substep} #{step.options.monitor_call_num}/4"
     if step.options.monitor_call_num <= 4
       step.options.monitor_call_num += 1
     end
     step.options.monitor_call_num > 4 # Once we've checked if finished four times - return false
  end


  def machine_failed!(step,machine)
     puts "Fake Machine failed!"
  end


  def machine_activated!(step,machine)
    puts "Fake Machine activated!" 
  end
end
