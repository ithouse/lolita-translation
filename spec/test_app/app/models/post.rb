class Post < ActiveRecord::Base
  include Lolita::Configuration
  include Lolita::Translation
  attr_accessible :title, :body
  translate :title, :body

  lolita
end