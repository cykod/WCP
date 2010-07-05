require 'spec_helper'

describe DeploymentsController do

  before { mock_user } 

  def mock_deployment(stubs={})
    @mock_deployment ||= mock_model(Deployment, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all deployments as @deployments" do
      Deployment.stub(:all) { [mock_deployment] }
      get :index
      assigns(:deployments).should eq([mock_deployment])
    end
  end

  describe "GET show" do
    it "assigns the requested deployment as @deployment" do
      Deployment.stub(:find).with("37") { mock_deployment }
      get :show, :id => "37"
      assigns(:deployment).should be(mock_deployment)
    end
  end

  describe "GET new" do
    it "assigns a new deployment as @deployment" do
      Deployment.stub(:new) { mock_deployment }
      get :new
      assigns(:deployment).should be(mock_deployment)
    end
  end

  describe "GET edit" do
    it "assigns the requested deployment as @deployment" do
      Deployment.stub(:find).with("37") { mock_deployment }
      get :edit, :id => "37"
      assigns(:deployment).should be(mock_deployment)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}) { mock_deployment(:save => true) }
        post :create, :deployment => {'these' => 'params'}
        assigns(:deployment).should be(mock_deployment)
      end

      it "redirects to the created deployment" do
        Deployment.stub(:new) { mock_deployment(:save => true) }
        post :create, :deployment => {}
        response.should redirect_to(deployment_url(mock_deployment))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved deployment as @deployment" do
        Deployment.stub(:new).with({'these' => 'params'}) { mock_deployment(:save => false) }
        post :create, :deployment => {'these' => 'params'}
        assigns(:deployment).should be(mock_deployment)
      end

      it "re-renders the 'new' template" do
        Deployment.stub(:new) { mock_deployment(:save => false) }
        post :create, :deployment => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested deployment" do
        Deployment.should_receive(:find).with("37") { mock_deployment }
        mock_deployment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :deployment => {'these' => 'params'}
      end

      it "assigns the requested deployment as @deployment" do
        Deployment.stub(:find) { mock_deployment(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:deployment).should be(mock_deployment)
      end

      it "redirects to the deployment" do
        Deployment.stub(:find) { mock_deployment(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(deployment_url(mock_deployment))
      end
    end

    describe "with invalid params" do
      it "assigns the deployment as @deployment" do
        Deployment.stub(:find) { mock_deployment(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:deployment).should be(mock_deployment)
      end

      it "re-renders the 'edit' template" do
        Deployment.stub(:find) { mock_deployment(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested deployment" do
      Deployment.should_receive(:find).with("37") { mock_deployment }
      mock_deployment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the deployments list" do
      Deployment.stub(:find) { mock_deployment }
      delete :destroy, :id => "1"
      response.should redirect_to(deployments_url)
    end
  end

end
