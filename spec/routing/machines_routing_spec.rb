require "spec_helper"

describe MachinesController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/machines" }.should route_to(:controller => "machines", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/machines/1" }.should route_to(:controller => "machines", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/machines/1/edit" }.should route_to(:controller => "machines", :action => "edit", :id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/machines/1" }.should route_to(:controller => "machines", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/machines/1" }.should route_to(:controller => "machines", :action => "destroy", :id => "1") 
    end

  end
end
