require 'spec_helper'

describe CompanyController do

  before { reset_and_mock_user }

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
      response.should redirect_to(company_url)
    end
  end

end

