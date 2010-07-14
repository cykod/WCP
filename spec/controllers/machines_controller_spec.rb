require 'spec_helper'

describe MachinesController do
  reset_models :users, :companies, :clouds, :machines, :machine_blueprints
  before { mock_user } 

  render_views

  let(:cloud) { @myself.company.add_cloud("Test Cloud") }
  let(:machine_blueprint) { MachineBlueprint.create(:launcher_class => 'FakeClass', :machine_image => '12343', :instance_type => 'ec2'  ) }

  before do 
    controller.stub(:current_cloud) { cloud }
    @m1 = Machine.create(:cloud_id => cloud.id, :machine_blueprint => machine_blueprint )
    @m2 = Machine.create(:cloud_id => cloud.id, :machine_blueprint => machine_blueprint )
  end

  it "should be able to list current machines" do
    get "index"
    response.should render_template("index")
  end

  it "should show a machine" do
    get "show", :id => @m1.id
    response.should render_template('show')
  end
  
  it "Should show the edit template" do
    get 'edit', :id => @m2.id
    response.should render_template('edit')
  end

  it "should update a machine" do
    put 'update', :id => @m1.id, :machine => { :name => 'Test Machine Name' } 
    response.should redirect_to(machine_url(@m1))
    @m1.reload
    @m1.name.should == 'Test Machine Name'
  end


end
