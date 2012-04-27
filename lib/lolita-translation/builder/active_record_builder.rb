require 'lolita-translation/builder/abstract_builder'

module Lolita
  module Translation

    module Builder
      class ActiveRecordBuilder < Lolita::Translation::Builder::AbstractBuilder

        def build_klass
          create_klass(ActiveRecord::Base)
        end

        def call_klass_class_methods
          add_ar_klass_associations
          add_ar_klass_validations
          add_ar_klass_class_methods
        end

        def update_base_klass
          call_base_klass_class_methods
          add_validations_to_base_klass
        end

        def override_klass_attributes(attributes)
          add_ar_klass_attr_accessible(attributes + default_attributes)
          expanded_attributes = attributes.inject({}){|hsh,attribute| 
            hsh[attribute] = attribute 
            hsh[:"#{attribute}_before_type_cast"] = attribute 
            hsh
          }
          super(expanded_attributes)
        end

        def association_name
          base_klass.to_s.demodulize.underscore.to_sym
        end

        def association_key
          :"#{association_name}_id"
        end

        def table_name
          base_klass.translations_table_name || "#{base_klass.table_name}_translations"
        end

        private

        def default_attributes
          [:locale]
        end

        def add_ar_klass_attr_accessible attributes
          klass.class_eval do 
            attr_accessible :locale, *attributes
          end
        end

        def add_ar_klass_associations
          klass.belongs_to association_name, :inverse_of => :translations
        end

        def add_ar_klass_validations
          ar_translation_builder = self

          klass.validates(:locale,{
            :presence => true, 
            :uniqueness => {:scope => association_key},
          })
          klass.validates(association_name, :presence => true)
          klass.validates_each(:locale) do |record, attr, value|
            original_record = record.send(ar_translation_builder.association_name)
            if original_record && original_record.default_locale.to_s == value.to_s 
              record.errors.add(attr, 'is used as default locale')
            end
          end
        end

        def add_ar_klass_class_methods
          ar_translation_builder = self
          klass.singleton_class.instance_eval do 
            define_method(:table_name) do 
              ar_translation_builder.table_name
            end
          end
        end

        def call_base_klass_class_methods
          ar_translation_builder = self
          base_klass.class_eval do 
            has_many(:translations, {
              :class_name => ar_translation_builder.class_name, 
              :foreign_key => ar_translation_builder.association_key, 
              :dependent => :destroy,
              :inverse_of => ar_translation_builder.association_name
            })
            accepts_nested_attributes_for :translations, :allow_destroy => true
          end

        end

        def add_validations_to_base_klass
          if base_klass.column_names.include?("default_locale")
            base_klass.validates :default_locale, :presence => true
          end
        end

      end
    end

  end
end