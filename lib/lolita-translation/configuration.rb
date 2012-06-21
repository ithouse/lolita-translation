require 'lolita-translation/translation_class_builder'
module Lolita
  module Translation

    def self.included(base)
      base.extend(Lolita::Translation::ORM::ClassMethods)
      base.class_eval do 
        include Lolita::Translation::ORM::InstanceMethods
      end
    end

    class Configuration
      attr_reader :klass, :attributes, :translation_class, :options
      alias :translation_attributes :attributes

      def initialize(base_klass, *args, &block)
        @options            = (args.respond_to?(:last) && args.last.is_a?(Hash) && args.pop) || {}
        @klass              = base_klass
        @attributes         = args
        if base_klass.table_exists?
          build_translation_class
          if block_given?
            block.call(self)
          end
        end
      end

      def association_name
        options[:association_name] || :translations
      end

      def locale_field_name
        options[:locale_field_name] || :default_locale
      end

      def association_key
        options[:association_key] || :"#{demodulized_class_name}_id"
      end

      def table_name
        options[:table_name] || "#{klass.table_name}_translations"
      end

      def demodulized_class_name
        klass.to_s.demodulize.underscore
      end

      private
      
      def build_translation_class
        @builder            = Lolita::Translation::TranslationClassBuilder.new(self.klass, self)
        @translation_class  = @builder.build_class
        @builder.override_attributes(@attributes)
      end

    end

  end
end 