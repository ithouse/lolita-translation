module Lolita
  module Configuration
    module Tab

      class Base

        # This class encapsulate all logic about tab that are translatable, original tab uses it only when it is neccessary
        class TranslationTabExtension
          attr_reader :tab, :dbi
          def initialize(tab)
            @tab = tab
            @dbi = tab.dbi
          end

          def translatable?
            is_dbi_klass_translatable? && tab_has_translatable_fields?
          end

          def build_form(resource) 
            resource.build_nested_translations 
            nested_form = create_translations_nested_form(resource)
            add_default_locale_field(resource)
            nested_form 
          end

          private

          def create_translations_nested_form(resource)
            nested_form = Lolita::Configuration::NestedForm.new(tab, translations_association_name) 
            nested_form.expandable = false
            nested_form.field_style = :normal
            nested_form.fields = fields_for_translation_nested_form(nested_form)
            nested_form
          end

          def fields_for_translation_nested_form(nested_form)
            t_attributes = dbi_klass_translation_attributes
            t_fields = tab.fields.reject do|field|
              !t_attributes.include?(field.name.to_sym)
            end
            t_fields << Lolita::Configuration::Factory::Field.add(nested_form.dbi,:locale,:string, :builder => :hidden)
            t_fields
          end

          def add_default_locale_field resource
            if resource.respond_to?(:"#{locale_field_name}=")
              locale_field = Lolita::Configuration::Factory::Field.add(dbi, locale_field_name, :string, :builder => :hidden)
              tab.fields << locale_field 
            end
          end

          def is_dbi_klass_translatable?
            (dbi.klass.respond_to?(:translations_configuration) && dbi.klass.respond_to?(:translate))
          end

          def tab_has_translatable_fields?
            (collect_possibly_translateble_fields & dbi_klass_translation_attributes).any?
          end

          def dbi_klass_translation_attributes
            transl_configuration = dbi.klass.translations_configuration
            transl_configuration && transl_configuration.attributes || []
          end

          def translations_association_name
            translations_configuration.association_name
          end

          def locale_field_name
            translations_configuration.locale_field_name
          end

          def translations_configuration
            dbi.klass.translations_configuration
          end


          def collect_possibly_translateble_fields
            tab.fields.reject{|field|
              field.dbi != dbi
            }.map(&:name)
          end

        end

        def translatable?
          translation_tab_extension.translatable?
        end

        def build_translations_nested_form(resource) 
          translation_tab_extension.build_form(resource)
        end

        private

        def translation_tab_extension
          @translation_tab_extension ||= TranslationTabExtension.new(self)
        end
      end

    end
  end
end