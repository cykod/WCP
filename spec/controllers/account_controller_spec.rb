require 'spec_helper'

describe AccountController do
  render_views

  before { reset_and_mock_user }

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
      response.should render_template('index')
    end
  end

  describe "POST 'update'" do

    it "should display an error if password doesn't match confirmation" do
      post 'update', :user => {  :password => 'baba', :password_confirmation => 'tester' } 
      response.should be_success
      response.body.should include("doesn't match confirmation")
    end

    it "should be successful with password and confirmation" do
      post 'update', :user => {  :password => 'test', :password_confirmation => 'test' } 
      response.should redirect_to(account_url)

    end
  end

end
