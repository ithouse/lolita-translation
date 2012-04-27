require File.expand_path('../boot', __FILE__)
require 'lolita'
if ENV["ORM"] == "active_record"
  require 'rails/all'
elsif ENV["ORM"] == "mongoid"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "active_resource/railtie"
  require "rails/test_unit/railtie"
  require "sprockets/railtie"
end

Bundler.require(:default, :test, Rails.env) if defined?(Bundler)

module Test
  class Application < Rails::Application
    config.root                       = File.expand_path("#{File.dirname(__FILE__)}/..")
    config.logger                     = Logger.new(File.join(config.root,"log","development.log"))
    config.active_support.deprecation = :log
    config.i18n.default_locale        = I18n.default_locale
    config.assets.enabled             = true
    #config.autoload_paths=File.expand_path("../#{File.dirname(__FILE__)}")
  end
end
