class Category < ActiveRecord::Base
  include Lolita::Configuration
  include Lolita::Translation
  attr_accessible :name, :default_locale
  translate :name
  lolita
end