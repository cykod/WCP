# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'

require 'rocking_chair'




# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec


  config.before(:suite) do
    #RockingChair.enable
  end

  config.before(:each) do
    # RockingChair::Server.reset
  end

  # If you'd prefer not to run each of your examples within a transaction,
  # uncomment the following line.
  # config.use_transactional_examples = false
end


module RSpec
 module Core 
  class ExampleGroup

    def self.reset_models(*tables)
      callback = lambda do 
        tables.each do |table|
          table.to_s.classify.constantize.all.map(&:destroy)
        end
      end
      before(:each,&callback)
    end



    def mock_user(email='tester@webiva.com',options = {})
      company = Company.create(:name => 'Super test company')
      @myself = user = User.create({:email => email,:password=>'tester',:company => company}.merge(options))
      controller.should_receive(:myself).at_least(1).and_return(user)
    end

    def reset_users
      User.all.map(&:destroy)
      Company.all.map(&:destroy)
    end

    def reset_clouds
      Cloud.all.map(&:destroy)
    end

    def reset_and_mock_user(email='tester@webiva.com',options={})
      reset_users
      mock_user(email,options)
    end
  end
 end
end
     

