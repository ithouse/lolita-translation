require 'lolita-translation/locale'

module Lolita
  module Translation

    class Locales
      include Enumerable

      attr_reader :locale_names 

      def initialize(locale_names)
        @locale_names = locale_names.sort
      end

      def each
        populate_locales!
        @locales.each do |locale|
          yield locale
        end
      end

      def by_resource_locale(resource)
        r_locale = resource_locale(resource)
        self.inject([]) do |result, locale|
          if r_locale.to_s == locale.name.to_s
            result.unshift(locale)
          else
            result.push(locale)
          end
          result 
        end
      end

      def active
        self.detect{|locale| locale.active?}
      end

      private

      def resource_locale(resource)
        transl_record = resource.translation_record
        transl_record && transl_record.default_locale || ::I18n.locale
      end

      def populate_locales!
        unless @locales 
          @locales = @locale_names.map do |locale_name|
            Lolita::Translation::Locale.new(locale_name)
          end
        end
      end
    end

  end
end