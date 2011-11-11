
require 'lolita'
require 'lolita-translation/string.rb'
require 'lolita-translation/modules'
require 'lolita-translation/model'
require 'lolita-translation/configuration'
if Lolita.rails3?
  require 'lolita-translation/rails'
end

module Lolita
  module Translation

    def self.included(base_class)
      base_class.extend(Lolita::Translation::SingletonMethods)
    end

    class << self
      def translatable?(tab)
        fields = tab.fields.reject{|field|
          field.dbi!=tab.dbi
        } 
        tab.dbi.klass.respond_to?(:translation_attrs) &&
        tab.dbi.klass.respond_to?(:translations) && (fields.map(&:name) & tab.dbi.klass.translation_attrs).any?
      end

      def create_translations_nested_form(resource,tab)
        resource.build_nested_translations 
        nested_form = Lolita::Configuration::NestedForm.new(tab,:translations) 
        nested_form.expandable = false
        nested_form.field_style = :normal
        
        fields = tab.fields.reject{|field|
          !resource.class.translation_attrs.include?(field.name.to_sym)
        }
        fields << Lolita::Configuration::Factory::Field.add(nested_form.dbi,:locale,:hidden)
        nested_form.fields=fields
        nested_form
      end
    end
  end
end

Lolita.add_module Lolita::Translation
