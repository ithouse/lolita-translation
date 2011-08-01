
require 'lolita-translation/string.rb'
require 'lolita-translation/has_translations.rb'
require 'lolita-translation/rails'

module Lolita
  module Configuration
    module Tab
      autoload :Translation, "lolita-translation/configuration/tab/translation"
    end
  end
end