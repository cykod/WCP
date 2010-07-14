require "spec_helper"

describe BlueprintsController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/blueprints" }.should route_to(:controller => "blueprints", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/blueprints/new" }.should route_to(:controller => "blueprints", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/blueprints/1" }.should route_to(:controller => "blueprints", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/blueprints/1/edit" }.should route_to(:controller => "blueprints", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/blueprints" }.should route_to(:controller => "blueprints", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/blueprints/1" }.should route_to(:controller => "blueprints", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/blueprints/1" }.should route_to(:controller => "blueprints", :action => "destroy", :id => "1") 
    end

  end
end
