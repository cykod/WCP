require 'spec_helper'

describe LoginController do
  render_views

  describe "login page" do
    it "should be successful" do
      get 'login'
      response.should be_success
    end
  end

  describe "Attempt to login" do
    it "should display an invalid login" do
      post 'login', :user => { :email => 'nope@nope.com', :password => 1243 }
      response.body.should include('Invalid Login')
    end

    it "should redirect a valid login" do
      User.create(:email => 'testerama@webiva.com', :password => 'something', :company => Company.create(:name => 'tester'))
      post 'login', :user => { :email => 'testerama@webiva.com', :password => 'something' }
      response.should redirect_to(dashboard_url)
    end
  end

  describe "Logout" do
    it "should let a user login and redirect to login" do
      mock_user
      post 'logout'
      response.should redirect_to(login_url)
      session[:user_id].should be_nil
    end
  end

  describe "GET 'missing_password'" do
    it "should be successful" do
      get 'missing_password'
      response.should be_success
    end
  end

end
