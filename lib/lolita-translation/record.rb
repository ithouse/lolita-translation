require 'i18n'
require 'lolita-translation/translated_string'

module Lolita
  module Translation

    class Record
      DEFAULT_LOCALE_STORAGE_FIELD = "default_locale"

      class AbstractRecord
        attr_reader :orm_record

        def initialize(orm_record)
          @orm_record = orm_record
        end

        def locale
          system_default_locale
        end

        def attribute name
          nil
        end

        def translated_attribute name, options = {}
          nil
        end

        private

        def system_default_locale
          ::I18n.default_locale
        end

        def locale_field
          DEFAULT_LOCALE_STORAGE_FIELD
        end

        def translation_string(str,attr_name)
          TranslatedString.new(str.to_s, self, attr_name)
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
          translation_record && translation_string(translation_record.attributes[name.to_s],name) || attribute(name)
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

      def initialize(original_record)
        @original_record  = original_record
        @orm_wrapper      = orm_wrapper
        @default_locale   = @orm_wrapper.locale
      end

      def attribute(name)
        if default_locale != system_current_locale
          @orm_wrapper.translated_attribute(name, :locale => system_current_locale)
        else
          @orm_wrapper.attribute(name)
        end
      end

      private

      def system_current_locale
        ::I18n.locale
      end

      def orm_wrapper
        if is_active_record?
          ARRecord.new(original_record)
        elsif is_mongoid_record?
          MongoidRecord.new(original_record)
        else
          AbstractRecord.new(original_record)
        end 
      end

      def is_mongoid_record?
        defined?(Mongoid::Document) && class_ancestors.include?(Mongoid::Document)
      end

      def is_active_record?
        defined?(ActiveRecord::Base) && class_ancestors.include?(ActiveRecord::Base)
      end

      def class_ancestors
        original_class.ancestors
      end

      def original_class
        original_record.class
      end

    end

  end
end