require "spec_helper"

describe MachineBlueprintsController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/machine_blueprints" }.should route_to(:controller => "machine_blueprints", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/machine_blueprints/new" }.should route_to(:controller => "machine_blueprints", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/machine_blueprints/1" }.should route_to(:controller => "machine_blueprints", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/machine_blueprints/1/edit" }.should route_to(:controller => "machine_blueprints", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/machine_blueprints" }.should route_to(:controller => "machine_blueprints", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/machine_blueprints/1" }.should route_to(:controller => "machine_blueprints", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/machine_blueprints/1" }.should route_to(:controller => "machine_blueprints", :action => "destroy", :id => "1") 
    end

  end
end
