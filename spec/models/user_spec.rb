require 'spec_helper'

describe User do
  before { reset_users }
  subject { User.new(:email=> 'testerama@tester.com' ,:password => 'tester', :company => Company.create(:name => 'Tester')) }

  it "new user should be invalid" do
    User.new.should_not be_valid 
  end

  it "should not be logged in" do
    subject.logged_in?.should be_false
  end

  it { subject.should be_valid }

  describe "Saved" do
    before { subject.save }

    it "should be logged in" do
      subject.logged_in?.should be_true
    end

    it "should have a salt and encrypted password" do 
      subject.encrypted_password.should_not be_nil
      subject.salt.should_not be nil
    end

    it "should be able to match a password" do
      subject.password_matches?("tester").should be_true
    end

    it "should be able to authenticate as user" do
      subject.should == User.authenticate("testerama@tester.com","tester")
    end
  end

end
