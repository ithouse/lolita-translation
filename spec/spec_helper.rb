# encoding: utf-8
# Now there are support only for "active_record"
ENV["ORM"] = "active_record"
# Set this to true if you want to launch rails application
USE_RAILS = true
# Set this true to use debugger, if your  ruby version supports debugger.
USE_DEBUGGER = true
# Set this to true to see HTML code coverage report
SHOW_REPORT = false


require 'header'
if USE_RAILS
  require 'rails_helper'
end

if ENV["ORM"] == "active_record"
  require 'ar_schema'
end

if USE_DEBUGGER
  require 'debugger'
end

require 'logger'
require 'ffaker'
require File.expand_path('lib/lolita-translation')


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
  end
end

at_exit do 
  if ::USE_RAILS
    if File.exist?(File.expand_path("spec/test_app/db/lolita-translation.db"))
      File.delete(File.expand_path("spec/test_app/db/lolita-translation.db"))
    end
  end
  if ::SHOW_REPORT
    CoverMe.complete!
  end
end
