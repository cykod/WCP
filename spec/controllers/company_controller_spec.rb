require 'spec_helper'

describe CompanyController do

  before { mock_user }

  describe "view company page" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "Update company information" do
    it "should be successful" do
      post 'update',  :company => { :name => 'New Name' }
      @myself.company.reload
      @myself.company.name.should == 'New Name'
      response.should redirect_to(company_config_url)
    end
  end

end

