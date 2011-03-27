require File.expand_path('../boot', __FILE__)


require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"


# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module WCP
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end
    config.secret_token = 'e46b16b9dbf3c379e9b9b9a2368579e4cee19c3c8b818ebb1962b3988b3a03c1b10998a3eb2bba66fe8b5d54563229fccd46e180cfcdff7569ef3d96194ff128'

    config.session_store = {
      :key    => '_WCP_session',
      :secret => '0009af6dffcbb006b899c255587ef2bdf6a7df04c28f58663c64bb1321c2c0bc16f004f2d69f2290292a31a280d265215e3d7ee86355cfe6a63177c89f6fad79'
    }

      config.action_view.javascript_expansions[:defaults] = ['jquery.min', 'rails', 'jquery-ui-1.8.2.custom.min']

    
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password

  end
end
