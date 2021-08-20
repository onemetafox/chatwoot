# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'ransack'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# require 'fat_free_crm/gem_ext/rails/engine'


module Chatwoot

  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.autoload_paths << Rails.root.join('lib')
    # config.eager_load_paths << Rails.root.join('lib')
    Rails.autoloaders.main.ignore(Rails.root.join('lib/azure'))
    # config.active_record.observers = :lead_observer, :opportunity_observer, :task_observer, :entity_observer unless ARGV.join.include?('assets:precompile')
    # This is required in production for zeitwerk to autoload the file
    config.paths.add File.join('app', 'bot'), glob: File.join('**', '*.rb')
    config.autoload_paths << Rails.root.join('app/bot/*')
    config.autoload_paths << Rails.root.join('lib/fat_free_crm*')
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators.javascripts = false
    config.generators.stylesheets = false

    # Custom chatwoot configurations
    config.x = config_for(:app).with_indifferent_access


  end

  def self.config
    @config ||= Rails.configuration.x
  end
end
# require 'fat_free_crm'

