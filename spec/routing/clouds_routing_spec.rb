require "spec_helper"

describe CloudsController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/clouds" }.should route_to(:controller => "clouds", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/clouds/new" }.should route_to(:controller => "clouds", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/clouds/1" }.should route_to(:controller => "clouds", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/clouds/1/edit" }.should route_to(:controller => "clouds", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/clouds" }.should route_to(:controller => "clouds", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/clouds/1" }.should route_to(:controller => "clouds", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/clouds/1" }.should route_to(:controller => "clouds", :action => "destroy", :id => "1") 
    end

  end
end
