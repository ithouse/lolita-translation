$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'lolita'


module Lolita
  # Lolita::Translation is module for all classes and module for data translation in Lolita. 
  # It have #locales method, that is is used to get all configured locales or all available locales.
  module Translation

    def self.locales
      unless @locales
        defined_locales = Lolita.locales.any? && Lolita.locales || ::I18n.available_locales
        @locales = Lolita::Translation::Locales.new(defined_locales)
      end
      @locales
    end

    def self.load!
      load_base!
      load_orm!
      load_lolita_extensions!
      if Lolita.rails3?
        load_rails_engine!
      end
    end

    def self.load_base!
      require 'lolita-translation/version'
      require 'lolita-translation/errors'
      require 'lolita-translation/utils'
      require 'lolita-translation/configuration'
      require 'lolita-translation/locales'
      require 'lolita-translation/translation_class_builder'
      require 'lolita-translation/record'
    end

    def self.load_orm!
      require 'lolita-translation/migrator'
      require 'lolita-translation/orm/mixin'
    end

    def self.load_lolita_extensions!
      require 'lolita-translation/lolita/tab_extension'
    end

    def self.load_rails_engine!
      require 'lolita-translation/rails'
    end
    
  end
end

Lolita::Translation.load!
