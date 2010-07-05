
require 'spec_helper'

describe DeploymentBlueprint do

  it "should be able to create and deploy a simple blue print" do
    company = Company.create(:name => 'Testerama')
    cloud = company.add_cloud(:name => "Test Cloud")


    blueprint = DeploymentBlueprint.create(:name => "Fake Deployment")
    blueprint.add_step("Test Deployment","Simple::FakeInstanceStep")

    cloud.deploy(blueprint,{})
    
    
  end
end
