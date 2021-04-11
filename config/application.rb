require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Robyn2
  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    
    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
    
    # Enable the asset pipeline
    config.assets.enabled = true
    
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    # allow frame inclusion from glass hotel (technique culled from http://stackoverflow.com/q/18445782) 
    config.action_dispatch.default_headers['X-Frame-Options'] = "ALLOW-FROM http://glasshotel.net/"

    # todo only force this in production mode?
    # config.force_ssl = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    
  end
end
