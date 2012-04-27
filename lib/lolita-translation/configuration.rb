module Lolita
  module Translation

    def self.included(base)
      base.extend(Lolita::Translation::ORM::ClassMethods)
      base.class_eval do 
        include Lolita::Translation::ORM::InstanceMethods
      end
    end

    class Configuration
      attr_reader :klass, :attributes, :translation_class
      alias :translation_attributes :attributes

      def initialize(base_klass, *args, &block)
        @options            = (args.respond_to?(:last) && args.last.is_a?(Hash) && args.pop) || {}
        @klass              = base_klass
        @attributes         = args
        build_translation_class
        if block_given?
          block.call(self)
        end
      end


      def method_missing method_name, *args, &block
        # if options.has_key?(method_name.to_sym)
        #   options[method_name.to_sym]
        # else
        #   super
        # end
      end

      private

      def build_translation_class
        @builder            = Lolita::Translation::TranslationClassBuilder.new(self.klass)
        @translation_class  = @builder.build_class
        @builder.override_attributes(@attributes)
      end

    end

  end
end 