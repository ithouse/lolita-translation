require 'lolita-translation/migrator'
module Lolita
  module Translation
    module Migrators
      class ActiveRecordMigrator < Lolita::Translation::Migrator 

        def migrate
          switch_stdout do 
            unless table_exist?
              create_table
              add_indexes
              reset_class_column_information
            else
              if change_table
                reset_class_column_information
              end
            end
          end
        end

        private

        def create_table
          ActiveRecord::Migration.create_table config.table_name do |t|
            t.integer config.association_key, :null => false
            t.string  :locale, :null => false, :limit => 5
            config.attributes.each do |attr|
              if col = column(attr)
                t.send(col.type, attr)
              end
            end
          end
        end

        def change_table
          any_column_removed = removed_columns.inject(false) do |result,attribute|
            ActiveRecord::Migration.remove_column(config.table_name, attribute)
            true
          end
          any_column_added = config.attributes.inject(false) do |result, attribute|
            if !translations_column(attribute)
              if col = column(attribute)
                ActiveRecord::Migration.add_column(config.table_name, attribute, col.type)
                result = true
              end
            end
            result
          end
          any_column_added || any_column_removed
        end

        def add_indexes
          ActiveRecord::Migration.add_index(
            config.table_name, 
            [config.association_key, :locale], {
              :unique => true, 
              :name => "#{config.table_name}_comb"
            }
          )
          ActiveRecord::Migration.add_index(
            config.table_name, 
            config.association_key,{
              :name => "#{config.table_name}_sim"
            }
          )
        end

        def content_columns
          config.translation_class.column_names - ["id", "locale", config.association_key.to_s]
        end

        def removed_columns
          content_columns - config.attributes.map{|a| a.to_s }
        end
        def reset_class_column_information
          config.translation_class.reset_column_information
        end

        def table_exist?
          ActiveRecord::Migration.table_exists?(config.table_name)
        end

        def column(name)
          klass.columns_hash[name.to_s]
        end

        def translations_column(name)
          config.translation_class.columns_hash[name.to_s]
        end 
      end

    end
  end
end