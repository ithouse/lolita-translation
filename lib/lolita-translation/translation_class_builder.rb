require 'lolita-translation/builder/active_record_builder'
require 'lolita-translation/builder/mongoid_builder'
module Lolita
  module Translation

    # Create ORM class for translations. For Post class it will create PostTranslation class, 
    # for News it will create NewsTranslation and so on
    class TranslationClassBuilder

      attr_reader :klass

      def initialize(base_class) 
        @klass = base_class
        detect_builder_class
      end

      def builder_available?
        !!@builder_class
      end

      def builder
        @builder ||= @builder_class && @builder_class.new(klass)
      end

      def build_class
        if builder
          builder.build_klass
          builder.call_klass_class_methods
          builder.update_base_klass
          builder.klass
        else
          raise Lolita::Translation::NoBuilderForClassError.new(klass)
        end
      end

      def override_attributes(attributes)
        if builder 
          builder.override_klass_attributes(attributes)
        else
          raise Lolita::Translation::NoBuilderForClassError.new(klass)
        end
      end

      private

      def detect_builder_class
        @builder_class ||= if defined?(ActiveRecord::Base) && klass.ancestors.include?(ActiveRecord::Base)
          Lolita::Translation::Builder::ActiveRecordBuilder
        elsif defined?(Mongoid::Document) && klass.ancestors.include?(Mongoid::Document)
          Lolita::Translation::Builder::MongoidBuilder
        else
          nil
        end 
      end
    end

  end
end