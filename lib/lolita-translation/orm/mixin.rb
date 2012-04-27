module Lolita
  module Translation

    module ORM

      module ClassMethods
        def translate *args, &block
          @translations_configuration ||= Lolita::Translation::Configuration.new(self,*args,&block)
        end
        # Backward compability
        alias :translations :translate

        def translations_configuration
          unless @translations_configuration
            raise Lolita::Translation::ConfigurationNotInitializedError.new(self)
          else
            @translations_configuration
          end
        end

        def translations_table_name
          translations_configuration.table_name
        end
      end

      module InstanceMethods

        def translation_record
          @translation_record ||= Lolita::Translation::Record.new(self)
        end

        def default_locale
          translation_record.default_locale
        end

      end

    end

  end
end