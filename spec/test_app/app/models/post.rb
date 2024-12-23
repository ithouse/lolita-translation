class Post < ActiveRecord::Base
  include Lolita::Configuration
  include Lolita::Translation
  translate :title, :body

  lolita

end
