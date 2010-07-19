require 'spec_helper'

describe MachineBlueprintsController do

  def mock_machine_blueprint(stubs={})
    @mock_machine_blueprint ||= mock_model(MachineBlueprint, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all machine_blueprints as @machine_blueprints" do
      MachineBlueprint.stub(:all) { [mock_machine_blueprint] }
      get :index
      assigns(:machine_blueprints).should eq([mock_machine_blueprint])
    end
  end

  describe "GET show" do
    it "assigns the requested machine_blueprint as @machine_blueprint" do
      MachineBlueprint.stub(:find).with("37") { mock_machine_blueprint }
      get :show, :id => "37"
      assigns(:machine_blueprint).should be(mock_machine_blueprint)
    end
  end

  describe "GET new" do
    it "assigns a new machine_blueprint as @machine_blueprint" do
      MachineBlueprint.stub(:new) { mock_machine_blueprint }
      get :new
      assigns(:machine_blueprint).should be(mock_machine_blueprint)
    end
  end

  describe "GET edit" do
    it "assigns the requested machine_blueprint as @machine_blueprint" do
      MachineBlueprint.stub(:find).with("37") { mock_machine_blueprint }
      get :edit, :id => "37"
      assigns(:machine_blueprint).should be(mock_machine_blueprint)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created machine_blueprint as @machine_blueprint" do
        MachineBlueprint.stub(:new).with({'these' => 'params'}) { mock_machine_blueprint(:save => true) }
        post :create, :machine_blueprint => {'these' => 'params'}
        assigns(:machine_blueprint).should be(mock_machine_blueprint)
      end

      it "redirects to the created machine_blueprint" do
        MachineBlueprint.stub(:new) { mock_machine_blueprint(:save => true) }
        post :create, :machine_blueprint => {}
        response.should redirect_to(machine_blueprint_url(mock_machine_blueprint))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved machine_blueprint as @machine_blueprint" do
        MachineBlueprint.stub(:new).with({'these' => 'params'}) { mock_machine_blueprint(:save => false) }
        post :create, :machine_blueprint => {'these' => 'params'}
        assigns(:machine_blueprint).should be(mock_machine_blueprint)
      end

      it "re-renders the 'new' template" do
        MachineBlueprint.stub(:new) { mock_machine_blueprint(:save => false) }
        post :create, :machine_blueprint => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested machine_blueprint" do
        MachineBlueprint.should_receive(:find).with("37") { mock_machine_blueprint }
        mock_machine_blueprint.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :machine_blueprint => {'these' => 'params'}
      end

      it "assigns the requested machine_blueprint as @machine_blueprint" do
        MachineBlueprint.stub(:find) { mock_machine_blueprint(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:machine_blueprint).should be(mock_machine_blueprint)
      end

      it "redirects to the machine_blueprint" do
        MachineBlueprint.stub(:find) { mock_machine_blueprint(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(machine_blueprint_url(mock_machine_blueprint))
      end
    end

    describe "with invalid params" do
      it "assigns the machine_blueprint as @machine_blueprint" do
        MachineBlueprint.stub(:find) { mock_machine_blueprint(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:machine_blueprint).should be(mock_machine_blueprint)
      end

      it "re-renders the 'edit' template" do
        MachineBlueprint.stub(:find) { mock_machine_blueprint(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested machine_blueprint" do
      MachineBlueprint.should_receive(:find).with("37") { mock_machine_blueprint }
      mock_machine_blueprint.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the machine_blueprints list" do
      MachineBlueprint.stub(:find) { mock_machine_blueprint }
      delete :destroy, :id => "1"
      response.should redirect_to(machine_blueprints_url)
    end
  end

end
