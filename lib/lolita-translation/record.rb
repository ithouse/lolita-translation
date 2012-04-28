require 'i18n'
require 'lolita-translation/translated_string'
require 'lolita-translation/utils'

module Lolita
  module Translation

    class Record
      DEFAULT_LOCALE_STORAGE_FIELD = "default_locale"

      class AbstractRecord
        attr_reader :orm_record

        def initialize(orm_record,configuration = nil)
          @configuration  = configuration
          @orm_record     = orm_record
        end

        def locale
          system_current_locale
        end

        def attribute name
          nil
        end

        def translated_attribute name, options = {}
          nil
        end

        def new_record?
          nil
        end

        def association_key
          nil
        end

        def has_translation_for?(locale)
          nil
        end
    
        private

        def adapter
          Lolita::DBI::Base.create(orm_record.class)
        end

        def system_current_locale
          ::I18n.locale
        end

        def locale_field
          DEFAULT_LOCALE_STORAGE_FIELD
        end

        def translation_string(str,attr_name)
          TranslatedString.new(str.to_s, self, attr_name)
        end

        def association_name
          @configuration && @configuration.association_name
        end

      end

      class ARRecord < AbstractRecord
        def locale
          if orm_record.class.column_names.include?(locale_field)
            orm_record.attributes[locale_field]
          else
            super
          end 
        end

        def attribute(name)
          translation_string(orm_record.attributes[name.to_s],name)
        end

        def translated_attribute(name, options = {})
          translation_record = find_translation_by_locale(options[:locale])
          if translation_record and str = translation_string(translation_record.attributes[name.to_s],name) and str.size > 0
            str
          else
            attribute(name)
          end
        end

        def new_reocrd?
          orm_record.new_record?
        end

        def association_key
          association = adapter.reflect_on_association(association_name)
          association.key
        end

        def has_translation_for?(locale)
          !!find_translation_by_locale(locale)
        end

        private

        def translations
          orm_record.translations
        end

        def find_translation_by_locale given_locale
          translations.detect{|translation| 
            translation.locale.to_s == given_locale.to_s
          }
        end
      end

      class MongoidRecord < AbstractRecord
        
      end

      attr_reader :original_record, :default_locale, :orm_wrapper

      def initialize(original_record, configuration = nil)
        @configuration    = configuration
        @original_record  = original_record
        @orm_wrapper      = get_orm_wrapper
        @default_locale   = @orm_wrapper.locale
      end

      def attribute(name)
        if default_locale.to_s == system_current_locale.to_s
          @orm_wrapper.attribute(name)
        else
          @orm_wrapper.translated_attribute(name, :locale => system_current_locale)
        end
      end

      def build_nested_translations
        available_locales.each do |locale|
          unless self.default_locale.to_s == locale.to_s 
            attributes = { :locale => locale.to_s }
            unless @orm_wrapper.new_record?
              attributes[@orm_wrapper.association_key] = original_record.id 
            end
            original_record.translations.build(attributes) unless orm_wrapper.has_translation_for?(locale)
          end
        end
      end


      private

      def available_locales
        ::I18n.available_locales
      end

      def system_current_locale
        ::I18n.locale
      end

      def get_orm_wrapper
        if is_active_record?
          ARRecord.new(original_record,@configuration)
        elsif is_mongoid_record?
          MongoidRecord.new(original_record,@configuration)
        else
          AbstractRecord.new(original_record,@configuration)
        end 
      end

      def is_mongoid_record?
        Lolita::Translation::Utils.mongoid_class?(original_class)
      end

      def is_active_record?
        Lolita::Translation::Utils.active_record_class?(original_class)
      end

      def original_class
        original_record.class
      end

    end

  end
end