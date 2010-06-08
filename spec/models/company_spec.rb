require 'spec_helper'

describe Company do

  it "should be able to create a company with a name" do
    company = Company.create(:name => 'Testerama')

    Company.all.should include(company)
  end
end
