require 'rails'
require File.expand_path("spec/test_app/config/enviroment")
require "rspec/rails"
require 'capybara/rails'
require 'capybara/rspec'
Capybara.default_driver = :webkit
