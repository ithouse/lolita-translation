module Lolita
  module Translation
    module ClassMethods
      
      def find_with_translations(*args,&block)
        unless ::I18n.locale == ::I18n.default_locale
          if args && args[0].kind_of?(Hash)
            args[0][:include] ||=[]
            args[0][:include] << :translations
          end
        end
        find_without_translations *args, &block
      end
      # creates translation table and adds missing fields
      # So at first add the "translations :name, :desc" in your model
      # then put YourModel.sync_translation_table! in db/seed.rb and run "rake db:seed"
      # Later adding more fields in translations array, just run agin "rake db:seed"
      # If you want to remove fields do it manualy, it's safer
      def sync_translation_table!
        out = StringIO.new
        $stdout = out
        self_adapter = Lolita::DBI::Base.create(self)
        translations_class = self.reflect_on_association(:translations).klass
        translations_adapter = Lolita::DBI::Base.create(translations_class)

        if translations_adapter.dbi.adapter_name == :active_record
          translations_table = translations_adapter.collection_name

          unless ActiveRecord::Migration::table_exists?(translations_table)
            ActiveRecord::Migration.create_table translations_table do |t|
              t.integer translations_class.master_id, :null => false
              t.string :locale, :null => false, :limit => 5
              columns_has_translations.each do |col|
                t.send(col.type,col.name)
              end
            end
            ActiveRecord::Migration.add_index translations_table, [translations_class.master_id, :locale], :unique => true
            translations_class.reset_column_information
          else
            changes = false
            columns_has_translations.each do |col|
              unless translations_class.columns_hash.has_key?(col.name)
                ActiveRecord::Migration.add_column(translations_table, col.name, col.type)
                changes = true
              end
            end
            translations_class.reset_column_information if changes
          end
        elsif translations_adapter.dbi.adapter_name == :mongoid
          unless translations_class.fields["locale"]
            translations_class.class_eval do
              field(self.master_id, :type => Integer)
              field :locale, :type => String
              columns_has_translations.each do |col|
                field col.name, :type => col.type
              end
              index(
                [
                  [ self.master_id, Mongo::ASCENDING ],
                  [ :locale, Mongo::ASCENDING ]
                ],
                unique: true
              )
            end
          else
            columns_has_translations.each do |col|
              unless translations_class.fields[col.name.to_s]
                translations_class.field(col.name,:type => col.type)
              end
            end
          end
        end
        $stdout = STDOUT
      end
    end

    module InstanceMethods

      # forces given locale
      # I18n.locale = :lv
      # a = Article.find 18
      # a.title
      # => "LV title"
      # a.in(:en).title
      # => "EN title"
      def in locale
        locale.to_sym == ::I18n.default_locale ? self : find_translation(locale)
      end
      
      def find_or_build_translation(*args)
        locale = args.first.to_s
        build = args.second.present?
        find_translation(locale) || (build ? self.translations.build(:locale => locale) : self.translations.new(:locale => locale))
      end

      def translation(locale)
        find_translation(locale.to_s)
      end

      def all_translations
        t = ::I18n.available_locales.map do |locale|
          [locale, find_or_build_translation(locale)]
        end
        ActiveSupport::OrderedHash[t]
      end

      def has_translation?(locale)
        return true if locale == ::I18n.default_locale
        find_translation(locale).present?
      end

      # if object is new, then nested slaves ar built for all available locales
      def build_nested_translations
        if (::I18n.available_locales.size - 1) > self.translations.size
          ::I18n.available_locales.clone.delete_if{|l| l == ::I18n.default_locale}.each do |l|
            options = {:locale => l.to_s}
            self_adapter = Lolita::DBI::Base.create(self.class)
            options[self_adapter.reflect_on_association(:translations).klass.master_id] = self.id unless self.new_record?
            self.translations.build(options) unless self.translations.map(&:locale).include?(l.to_s)
          end
        end
      end

      def find_translation(locale)
        locale = locale.to_s
        translations.detect { |t| t.locale == locale }
      end
    end
  end
end