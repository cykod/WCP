


class Configure::WebivaRoleSetup < Configure::Base

  def configure
    client = ChefClient.new

    role = client.find_role('webiva_app_server')

    if !role
      @create_role = true
      role = client.new_role('webiva_app_server','Primary role for Webiva App Servers')
    end

    role['run_list'] = generate_run_list

    if @create_role
      client.create_role(role)
    else
      client.save_role(role)
    end
  end


  def generate_run_list
    recipes = ['apache2','mysql','memcached','git','imagemagick','imagemagick::rmagick','build-essential',
               'libopenssl-ruby','imagesize','rake','libxslt','zip','passenger_apache2','memcache-ruby',
               'apache2::mod_xsendfile', 'apache2::mod_upload_progress']

    recipes.map { |r| "recipe[#{r}]" }
  end
end
