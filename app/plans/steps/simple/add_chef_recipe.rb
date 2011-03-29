class Steps::Simple::AddChefRecipe < Steps::Base

  step_info "Add Chef Recipies to the selected machines", :substeps => 2

  deployment_parameter(:machines, Proc.new { |deployment|
    { :as => :check_boxes, 
      :collection => deployment.cloud.server_select_options
    }
  })

  deployment_parameter :recipes, :as => :text, :rows =>10



  class Options < HashModel

  end


  def execute!(step)
    cloud = deployment.cloud

    options = deployment.deployment_options
    recipes = options.recipes.split("\n").map(&:strip).reject(&:blank?)

    machine_list = cloud.cloud_machines(options.machines)

    client = ChefClient.new
    if step.substep == 0 
      machine_list.each do |machine|
        client.add_to_run_list(machine,recipes)
      end
    elsif step.substep == 1 
      deployment.run_chef_client(machine_list)
    end
  end

  def finished?(step)
    true
  end


  def machine_failed!(step,machine)
  end


  def machine_activated!(step,machine)
   #
  end
end
