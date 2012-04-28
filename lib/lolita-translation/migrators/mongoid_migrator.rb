require 'lolita-translation/migrator'

module Lolita
  module Translation
    module Migrators      
      class MongidMigrator

        def migrate
          if collection_exist?
            create_collection_struct
            add_indexes
          else
            change_collection_struct
          end
           unless translations_class.fields["locale"]
              
            else
              
            end
        end

        private

        def create_collection_struct
          orig_config = config

          config.translations_class.class_eval do
            field(orig_config.association_key, :type => Integer)
            field :locale, :type => String
            orig_config.attributes.each do |attribute|
              if col = field(attribute)
                field col.name, :type => col.type
              end
            end
          end
        end

        def change_collection_struct
          config.attributes.each do |attribute|
            unless translations_field(attribute)
              if col = field(attribute)
                config.translations_class.field(col.name, :type => col.type)
              end
            end
          end
        end

        def add_indexes
          orig_config = config 

          config.translations_class.class_eval do 
            index(
              [
                [ orig_config.association_key, Mongo::ASCENDING ],
                [ :locale, Mongo::ASCENDING ]
              ],
              unique: true, background: true
            )
            index( orig_config.association_key, Mongo::ASCENDING, background: true)
          end
        end

        def collection_exist?
          config.translations_class.fields["locale"]
        end

        def field(name)
          klass.fields.detect do |field|
            field.name.to_s == name.to_s
          end
        end

        def translations_field(name)
          config.translations_class.fields.detect do |field|
            field.name.to_s == name.to_s
          end
        end
      end
    end
  end
end