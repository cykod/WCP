require 'spec_helper'

describe CloudsController do

  before { mock_user } 

  let(:mock_cloud) { Cloud.new(:name => 'Test Cloud',:company_id => @myself.company_id) }
  let(:created_cloud) { Cloud.create(:name => 'Test Cloud',:company_id => @myself.company_id) }

  describe "GET index" do
    it "assigns all clouds as @clouds" do
      created_cloud
      get :index
      assigns(:clouds).should eq([created_cloud])
    end
  end

  describe "GET show" do
    it "should display the cloud" do
      get :show, :id => created_cloud.id
      response.should render_template('show')
    end
  end

  describe "GET new" do
    it "assigns a new cloud as @cloud" do
      get :new
      response.should render_template('new')
    end
  end

  describe "GET edit" do
    it "render the edit template" do
      get :edit, :id => created_cloud.id
      response.should render_template('edit')
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created cloud as @cloud" do
        @cloud = Cloud.new({:name => "Test Name" })
        Cloud.should_receive(:new).and_return(@cloud)
        @cloud.should_receive(:save_cloud_databag).and_return(true)
        post :create, :cloud => {:name => "Test Name" }
        cloud = Cloud.first
        response.should redirect_to(cloud_url(cloud))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        post :create, :cloud => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested cloud" do
        @company.should_receive(:company_cloud).with(created_cloud.id.to_s).and_return(created_cloud)

        created_cloud.should_receive(:save_cloud_databag)
        put :update, :id => created_cloud.id.to_s, :cloud => {'name' => 'My Test Cloud Name' }

        created_cloud.reload()
        created_cloud.name.should == 'My Test Cloud Name'
        response.should redirect_to(cloud_url(created_cloud))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        put :update, :id => created_cloud.id, :cloud => { :name => '' }
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested cloud" do
      Cloud.should_receive(:find).with(created_cloud.id) { created_cloud }
      created_cloud.should_receive(:destroy)
      delete :destroy, :id => created_cloud.id
      response.should redirect_to(clouds_url)
    end
  end

end
