# encoding: utf-8
# Now there are support only for "active_record"
ENV["ORM"] = "active_record"

if ENV["ORM"] == "active_record"
  require 'ar_schema'
end

require 'rails_helper'
require 'rspec/collection_matchers'

unless ENV['CI']
  require 'byebug'
end

require 'logger'

require 'simplecov'
SimpleCov.start

Capybara.server = :webrick

# setup I18n
I18n.available_locales = [:en,:lv,:ru,:fr]
I18n.default_locale = :lv
I18n.locale = :en
Lolita.locales = I18n.available_locales

RSpec.configure do |config|
  config.before(:each) do
    if ENV["ORM"] == "active_record"
      ::ARSchema.clean!
    end
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.mock_with :rspec
    config.order = 'rand:3455'
    config.use_transactional_fixtures = true
  end
end

at_exit do
  if File.exist?(File.expand_path("spec/test_app/db/lolita-translation.db"))
    File.delete(File.expand_path("spec/test_app/db/lolita-translation.db"))
  end
end
