class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'master'
  before_filter :authenticate
  before_filter :generate_menu

  helper_method :myself

  hide_action :current_tab
  def current_tab; ''; end

  def self.current_tab(tb)
    define_method(:current_tab) do 
      tb
    end
  end

  protected

  def current_company
    myself.company
  end

  def current_cloud
    current_company.clouds[0]
  end


  def generate_menu
    @current_tab = current_tab 

    if !login_controller?
      @main_menu = [
        { :url => dashboard_url,
          :name => "Dashboard" },
        { :url => clouds_url,
          :name => "Clouds" },
        { :url => machines_url,
          :name => "Machines" },
        { :url => deployments_url,
          :name => "Deployments" },
        { :url => company_config_url,
          :name => "Company" }
      ]
      if myself.admin?
        @main_menu << { :url => companies_url,
                        :name => "Companies" }
        @main_menu << { :url => blueprints_url,
                        :name => "Blueprints" }
      end
    else
      @main_menu = [
        { :url => login_url,
          :name => 'Login'
      }
      ]

    end

    @main_menu.each do |item|
      item[:active] = true if item[:name] == @current_tab
    end
  end

  def login_controller?; false; end

  def myself(reload=false)
    return @myself if @myself && !reload

    if session[:user_id]
      @myself = User.find(session[:user_id])
    else
      @myself = User.new
    end
  end

  def authenticate
    unless self.login_controller? || myself.logged_in?
      redirect_to login_url
    end
  end
end
