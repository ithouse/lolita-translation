module Lolita
  module Translation

    module ORM

      module ClassMethods
        def translate *args, &block
          @translations_configuration ||= Lolita::Translation::Configuration.new(self,*args,&block)
        end

        def translations_configuration
          unless @translations_configuration
            raise Lolita::Translation::ConfigurationNotInitializedError.new(self)
          else
            @translations_configuration
          end
        end

        def sync_translation_table!
          migrator = Lolita::Translation::Migrator.create(self)
          migrator.migrate
        end

      end

      module InstanceMethods

        def translations_configuration
          self.class.translations_configuration
        end

        def translation_record
          @translation_record ||= Lolita::Translation::Record.new(self, translations_configuration)
        end

        def original_locale
          translation_record.default_locale
        end

        def original_locale=(value)
          translation_record.default_locale = value
        end

        def build_nested_translations
          translation_record.build_nested_translations
        end

        def in(locale,&block)
          translation_record.in(locale,&block) 
        end

      end

    end

  end
end