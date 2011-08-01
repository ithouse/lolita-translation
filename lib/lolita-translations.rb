
require 'lolita-translations/string.rb'
require 'lolita-translations/has_translations.rb'
require 'lolita-translations/rails'

module Lolita
  module Configuration
    module Tab
      autoload :Translation, "lolita-translations/configuration/tab/translation"
    end
  end
end