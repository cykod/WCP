class LoginController < ApplicationController
  def login
    @user = User.new(params[:user])
    if request.post? 
      user = User.authenticate(params[:user][:email],params[:user][:password])
      if user
        register_login(user)
        redirect_to dashboard_url
      else 
        flash.now[:notice] = "Invalid Login"
      end
    end
  end

  def missing_password
  end

  def logout
    unregister_login if myself.logged_in?
    redirect_to login_url
  end


  protected

  def login_controller?; true; end

  def register_login(user)
    session[:user_id] = user.id
    @myself = user
  end

  def unregister_login
    session[:user_id] = nil
    @myself = nil
  end
end
