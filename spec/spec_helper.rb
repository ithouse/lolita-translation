# encoding: utf-8
ENV["ORM"] = "active_record"
USE_RAILS = false
USE_DEBUGGER = true
require 'header'

if USE_RAILS
  require 'ar_schema'
  require 'rails_helper'
end

if USE_DEBUGGER
  require 'ruby-debug'
end

require 'logger'
require 'ffaker'
require File.expand_path('lib/lolita-translation')


# setup I18n
I18n.available_locales = [:en,:lv,:ru,:fr]
I18n.default_locale = :lv
I18n.locale = :en


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
  #CoverMe.complete!
end
