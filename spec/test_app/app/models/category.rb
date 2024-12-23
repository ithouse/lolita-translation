class Category < ActiveRecord::Base
  include Lolita::Configuration
  include Lolita::Translation
  translate :name
  lolita
end
