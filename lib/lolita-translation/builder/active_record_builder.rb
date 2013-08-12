require 'lolita-translation/builder/abstract_builder'

module Lolita
  module Translation

    module Builder
      class ActiveRecordBuilder < Lolita::Translation::Builder::AbstractBuilder

        def initialize base_klass, configuration = nil
          super(base_klass,configuration, ActiveRecord::Base)
        end

        def build
          add_ar_klass_associations
          add_ar_klass_validations
          call_base_klass_class_methods
          add_validations_to_base_klass
        end

        def override_klass_attributes(attributes)
          add_ar_klass_attr_accessible(attributes + default_attributes)
          add_ar_klass_table_name(self.table_name)
          expanded_attributes = attributes.inject({}){|hsh,attribute|
            hsh[attribute] = attribute
            hsh
          }
          super(expanded_attributes)
        end

        private

        def default_attributes
          [:locale]
        end

        def add_ar_klass_attr_accessible attributes
          ar_translation_builder = self
          klass.class_eval do
            attr_accessible :locale, *attributes
            self.table_name = ar_translation_builder.table_name
          end
        end

        def add_ar_klass_table_name name
          klass.class_eval do
            self.table_name = name
          end
        end

        def add_ar_klass_associations
          if self.configuration
            klass.belongs_to association_name
          end
        end

        def add_ar_klass_validations
          if self.configuration
            ar_translation_builder = self

            klass.validates(:locale,{
              :presence => true,
              :uniqueness => {:scope => association_key},
            })
            klass.validates(association_name, :presence => true, :on => :update)
            klass.validates_each(:locale) do |record, attr, value|
              original_record = record.send(ar_translation_builder.association_name)
              if original_record && original_record.original_locale.to_s == value.to_s
                record.errors.add(attr, 'is used as default locale')
              end
            end
          end
        end

        def call_base_klass_class_methods
          if self.configuration
            base_klass.has_many(translations_association_name, {
              :class_name => class_name,
              :foreign_key => association_key,
              :dependent => :destroy
            })
            base_klass.accepts_nested_attributes_for translations_association_name, :allow_destroy => true, :reject_if => nested_attributes_rejection_proc
            base_klass.attr_accessible :translations_attributes,  locale_field_name
          end
        end

        def nested_attributes_rejection_proc
          Proc.new{|attrs|
            !configuration_attributes.detect{|attr| !attrs[attr].blank? }
          }
        end

        def add_validations_to_base_klass
          if base_klass.column_names.include?(locale_field_name.to_s)
            base_klass.validates locale_field_name, :presence => true
            base_klass.before_validation do
              def_locale = self.send(self.translations_configuration.locale_field_name)
              unless def_locale
                self.send(:"#{self.translations_configuration.locale_field_name}=",self.translation_record.system_current_locale)
              end
            end
          end
        end

      end
    end

  end
end