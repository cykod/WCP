require 'spec_helper'

describe Deployment do

  describe "DeploymentLogs" do
    let(:deployment) { Deployment.create(:cloud => mock_cloud,
                                       :blueprint => Blueprint.create(:name => 'Fake Blueprint' )) }


    it "should be able to create deployment log entries" do

      deployment.log("This is a log message")
      deployment.log("This is another log message")

      deployment.write_log

      deployment.deployment_logs[0].messages.should == [ 'This is a log message', 'This is another log message'] 
    end

  end


  describe "Running a simple deployment" do

    let(:cloud) { mock_cloud }
    let(:blueprint) { Blueprint.create(:name => "Fake Deployment") }
    let(:input_deployment) { Deployment.new(:blueprint => blueprint) }

    it "Should be able to run thorugh a simple deployment" do
      blueprint.add_step("Test Deployment","Steps::Testing::DummyStep")

      output_deployment = cloud.deploy(input_deployment)

      cloud.status.should == 'deploying'
      output_deployment.status.should == 'deploying'

      monitor = DeploymentMonitor.first
      monitor.deployment.should == output_deployment
      monitor.monitor_cycle

      output_deployment.reload.status.should == 'deployed'
      cloud.reload.status.should == 'normal'
    end

    it "Should be able to run thorugh a multi-step deployment" do
      blueprint.add_step("Test Deployment","Steps::Testing::DummyStep")
      blueprint.add_step("Test Deployment","Steps::Testing::DummyStep")

      output_deployment = cloud.deploy(input_deployment)

      cloud.status.should == 'deploying'
      output_deployment.status.should == 'deploying'

      DeploymentMonitor.monitor_deployments

      output_deployment.reload.status.should == 'deploying'
      output_deployment.active_step.should == 1
      cloud.reload.status.should == 'deploying'

      DeploymentMonitor.monitor_deployments

      output_deployment.reload.status.should == 'deployed'
      output_deployment.active_step.should == 2
      cloud.reload.status.should == 'normal'

      DeploymentMonitor.monitor_deployments

      output_deployment.reload.status.should == 'deployed'
      output_deployment.active_step.should == 2
      cloud.reload.status.should == 'normal'
    end

    it "Should be able to run thorugh a multi-step deployment (with multi-substep steps)" do
      blueprint.add_step("Test Deployment","Steps::Testing::DummyMultiSubStep")
      blueprint.add_step("Test Deployment","Steps::Testing::DummyMultiSubStep")

      output_deployment = cloud.deploy(input_deployment)

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 1

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 2

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 3
      cloud.reload.status.should == 'deploying'

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 4
      cloud.reload.status.should == 'normal'
    end

    it "Should be able to log inside of the step" do
      blueprint.add_step("Test Deployment","Steps::Testing::LoggingStep")

      output_deployment = cloud.deploy(input_deployment)

      output_deployment.deployment_logs.length.should == 1
      output_deployment.deployment_logs.last.messages.should == [ 'This is substep 0' ]

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 1
      
      output_deployment.deployment_logs.length.should == 2
      output_deployment.deployment_logs.last.messages.should == [ 'This is substep 1' ]

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 2

      cloud.reload.status.should == 'normal'
    end


    it "Should be able to write config between steps" do
      blueprint.add_step("Test Deployment","Steps::Testing::WriteConfigStep")


      output_deployment = cloud.deploy(input_deployment)

      output_deployment.step_data(0).config.dummy_config.should == "We're at substep: 0"

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 1

      output_deployment.step_data(1).config.dummy_config.should == "We're at substep: 1"

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 2


      output_deployment.step_data(2).config.dummy_config.should == "We're at substep: 2"

      DeploymentMonitor.monitor_deployments
      output_deployment.reload.active_step.should == 3

      output_deployment.step_data(2).config.dummy_config.should == "We're at substep: 2"

      cloud.reload.status.should == 'normal'
    end

  end


end
