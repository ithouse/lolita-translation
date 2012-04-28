require 'lolita-translation/builder/active_record_builder'
require 'lolita-translation/builder/mongoid_builder'
require 'lolita-translation/utils'

module Lolita
  module Translation

    # Create ORM class for translations. For Post class it will create PostTranslation class, 
    # for News it will create NewsTranslation and so on
    class TranslationClassBuilder

      attr_reader :klass

      def initialize(base_class, configuration = nil) 
        @klass          = base_class
        @configuration  = configuration
        detect_builder_class
      end

      def builder_available?
        !!@builder_class
      end

      def builder
        @builder ||= @builder_class && @builder_class.new(klass, @configuration)
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
        @builder_class ||= if Lolita::Translation::Utils.active_record_class?(klass)
          Lolita::Translation::Builder::ActiveRecordBuilder
        elsif Lolita::Translation::Utils.mongoid_class?(klass)
          Lolita::Translation::Builder::MongoidBuilder
        else
          nil
        end 
      end
    end

  end
end