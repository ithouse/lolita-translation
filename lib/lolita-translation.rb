
require 'lolita-translation/string.rb'
require 'lolita-translation/has_translations.rb'
require 'lolita-translation/rails'

module Lolita
  module Translation
    class << self
      def translatable?(tab)
        tab.dbi.klass.respond_to?(:translation_attrs) &&
        tab.dbi.klass.respond_to?(:translations) && (tab.fields.map(&:name) & tab.dbi.klass.translation_attrs).any?
      end

      def create_translations_nested_form(resource,tab)
        resource.build_nested_translations 
        nested_form = Lolita::Configuration::NestedForm.new(tab,:translations) 
        nested_form.expandable = false
        nested_form.field_style = :normal
        
        fields = tab.fields.reject{|field|
          !resource.class.translation_attrs.include?(field.name.to_sym)
        }
        fields << Lolita::Configuration::Field.add(nested_form.dbi,:locale,:hidden)
        nested_form.fields=fields
        nested_form
      end
    end
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/form").before do
  tab = self.component_locals[:tab]
  if Lolita::Translation.translatable?(tab)
    self.send(:render_component,"lolita/translation",:switch, :tab => tab)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/fields").after do
  tab = self.component_locals[:tab]
  if Lolita::Translation.translatable?(tab)
    self.render_component Lolita::Translation.create_translations_nested_form(self.resource,tab)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/fields").around do
  tab = self.component_locals[:tab]
  if Lolita::Translation.translatable?(tab)
    self.send(:render_component,"lolita/translation",:language_wrap,:tab => tab, :content => let_content)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/nested_form/fields").around do
  tab = self.component_locals[:nested_form].parent
  if Lolita::Translation.translatable?(tab)
    self.send(:render_component,"lolita/translation",:language_wrap, :tab => tab, :content => let_content)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tabs/display").before do
  self.render_component "lolita/translation", :assets
end