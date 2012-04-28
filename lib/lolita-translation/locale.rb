require 'i18n'

module Lolita
  module Translation

    class Locale
      attr_accessor :name 
      alias :short_name :name 

      def initialize(name)
        @name = name
      end

      def humanized_short_name
        self.name.to_s.sub(/^(\w{1})(\w+)/) do 
          "#{$1.to_s.upcase}#{$2}"
        end
      end

      def active?
        self.name == current_locale
      end

      private

      def current_locale
        ::I18n.locale
      end
    end

  end
end