class AccountController < ApplicationController
  current_tab "My Account"

  def index
    @user = myself
    @user.edit_account
  end

  def update
    index
    @user.attributes = params[:user].slice(:email,:first_name,:last_name,:password,:password_confirmation) if params[:user]
    if @user.valid? && @user.save
      flash[:notice] = "Your account settings have been updated"                      
      return redirect_to account_url
    end
    
    render :action => 'index'
  end

end
