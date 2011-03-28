# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'



# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec


  config.before(:suite) do
  end

  config.after(:each) do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end

  config.before(:each) do
  end

  # If you'd prefer not to run each of your examples within a transaction,
  # uncomment the following line.
  # config.use_transactional_examples = false
end


module RSpec
 module Core 
  class ExampleGroup

    def mock_user(email='tester@webiva.com',options = {})
      @company = Company.create(:name => 'Super test company')
      @myself = user = User.create({:email => email,:password=>'tester',:company => @company}.merge(options))
      controller.stub!(:myself).and_return(user)
      @company.reload
      controller.stub!(:current_company).and_return(@company)
    end

    def mock_cloud(name = 'Test Cloud', company_name = "Test Company")
      @company = Company.create(:name => company_name) 
      @cloud = @company.add_cloud(name)
    end

  end
 end
end
     

