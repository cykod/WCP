require 'spec_helper'

describe Blueprint do

  it "should be able to create and deploy a simple blue print" do
    cloud = mock_cloud

    blueprint = Blueprint.create(:name => "Fake Deployment")
    blueprint.add_step("Test Deployment","Steps::Testing::DummyStep")

    input_deployment = Deployment.new(:blueprint => blueprint)

    output_deployment = cloud.deploy(input_deployment)
    
  end
end
