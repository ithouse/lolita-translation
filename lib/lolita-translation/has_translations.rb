require 'stringio'

module Lolita
  module Translation
    module SingletonMethods
      # Provides ability to add the translations for the model using delegate pattern.
      # Uses has_many association to the ModelNameTranslation.
      #
      # For example you have model Article with attributes title and text.
      # You want that attributes title and text to be translated.
      # For this reason you need to generate new model ArticleTranslation.
      # In migration you need to add:
      #
      #   create_table :article_translations do |t|
      #     t.references :article, :null => false
      #     t.string :locale, :length => 2, :null => false
      #     t.string :name, :null => false
      #   end
      #
      #   add_index :articles, [:article_id, :locale], :unique => true, :name => 'unique_locale_for_article_id'
      #
      # And in the Article model:
      #
      #   translations :title, :text
      #
      # This will adds:
      #
      # * named_scope (translated) and has_many association to the Article model
      # * locale presence validation to the ArticleTranslation model.
      #
      # Notice: if you want to have validates_presence_of :article, you should use :inverse_of.
      # Support this by yourself. Better is always to use artile.translations.build() method.
      #
      # For more information please read API. Feel free to write me an email to:
      # dmitry.polushkin@gmail.com.
      #
      # ===
      #
      # You also can pass attributes and options to the translations class method:
      #
      #   translations :title, :text, :fallback => true, :writer => true, :nil => nil
      #
      # ===
      #
      # Configuration options:
      # 
      # * <tt>:fallback</tt> - if translation for the current locale not found.
      #   By default true.
      #   Uses algorithm of fallback:
      #   0) current translation (using I18n.locale);
      #   1) default locale (using I18n.default_locale);
      #   2) :nil value (see <tt>:nil</tt> configuration option)
      # * <tt>:reader</tt> - add reader attributes to the model and delegate them
      #   to the translation model columns. Add's fallback if it is set to true.
      # * <tt>:writer</tt> - add writer attributes to the model and assign them
      #   to the translation model attributes.
      # * <tt>:nil</tt> - when reader cant find string, it returns by default an
      #   empty string. If you want to change this setting for example to nil,
      #   add :nil => nil
      #
      # ===
      #
      # When you are using <tt>:writer</tt> option, you can create translations using
      # update_attributes method. For example:
      #
      #   Article.create!
      #   Article.update_attributes(:title => 'title', :text => 'text')
      #
      # ===
      #
      # <tt>translated</tt> named_scope is useful when you want to find only those
      # records that are translated to a specific locale.
      # For example if you want to find all Articles that is translated to an english
      # language, you can write: Article.translated(:en)
      #
      # <tt>has_translation?(locale)</tt> method, that returns true if object's model
      # have a translation for a specified locale
      #
      # <tt>translation(locale)</tt> method finds translation with specified locale.
      #
      # <tt>all_translations</tt> method that returns all possible translations in
      # ordered hash (useful when creating forms with nested attributes).
      def translations *attrs
        include Lolita::Translation::InstanceMethods
        options = {
          :fallback => true,
          :reader => true,
          :writer => false,
          :nil => ''
        }.merge(attrs.extract_options!)
        options.assert_valid_keys([:fallback, :reader, :writer, :nil,:table_name])
        self.extend(Lolita::Translation::ClassMethods)
        self.class_eval do
          translation_class_name = "#{self.name}Translation"
          translation_class = self.define_translation_class(translation_class_name, attrs,options)
          belongs_to = self.name.demodulize.underscore.to_sym

          write_inheritable_attribute :has_translations_options, options
          class_inheritable_reader :has_translations_options

          write_inheritable_attribute :columns_has_translations, (columns rescue []).collect{|col| col if attrs.include?(col.name.to_sym)}.compact
          class_inheritable_reader :columns_has_translations
          
          if options[:reader]
            attrs.each do |name|
              send :define_method, name do
                unless ::I18n.default_locale == ::I18n.locale
                  translation = self.translation(::I18n.locale)
                  if translation.nil?
                    if has_translations_options[:fallback]
                      (self[name].nil? || self[name].blank?) ? has_translations_options[:nil] : self[name].set_origins(self,name)
                    else
                      has_translations_options[:nil]
                    end
                  else
                    if @return_raw_data
                      (self[name].nil? || self[name].blank?) ? has_translations_options[:nil] : self[name].set_origins(self,name)
                    else
                      value = translation.send(name) and value.set_origins(self,name)
                    end
                  end
                else
                  (self[name].nil? || self[name].blank?) ? has_translations_options[:nil] : self[name].set_origins(self,name)
                end
              end
            end
          end

          @translation_attrs = attrs
          def self.translation_attrs
            @translation_attrs
          end
          #adapter = Lolita::DBI::Base.create(self)
          has_many :translations, :class_name => translation_class_name, :foreign_key => translation_class.master_id, :dependent => :destroy
          accepts_nested_attributes_for :translations, :allow_destroy => true, :reject_if => proc { |attributes| columns_has_translations.collect{|col| attributes[col.name].blank? ? nil : 1}.compact.empty? }
          translation_class.belongs_to belongs_to
          translation_class.validates_presence_of :locale
          translation_class.validates_uniqueness_of :locale, :scope => translation_class.master_id

          # Workaround to support Rails 2
          scope_method =:scope 

          send scope_method, :translated, lambda { |locale| 
            where("#{translation_class.table_name}.locale = ?", locale.to_s).joins(:translations)
          }

          class << self

            def find_with_translations(*args,&block)
              unless ::I18n.locale == ::I18n.default_locale
                if args && args[0].kind_of?(Hash)
                  args[0][:include] ||=[]
                  args[0][:include] << :translations
                end
              end
              find_without_translations *args, &block
            end
            alias_method_chain :find, :translations
          end

        end
      end
    end

    module ClassMethods
      # adds :translations to :includes if current locale differs from default
      #FIXME is this enough with find or need to create chain for find_last, find_first and others?
      # def find(*args)
      #   if args[0].kind_of?(Hash)
      #     args[0][:include] ||= []
      #     args[0][:include] << :translations
      #   end unless I18n.locale == I18n.default_locale
      #   find_without_translations(*args)
      # end

      # Defines given class recursively
      # Example:
      # create_class('Cms::Text::Page', Object, ActiveRecord::Base)
      # => Cms::Text::Page
      def create_class(class_name, parent, superclass=nil, &block)
        first,*other = class_name.split("::")
        if other.empty?
          klass = superclass ? Class.new(superclass, &block) : Class.new(&block)
          parent.const_set(first, klass)
        else
          klass = Class.new
          parent = unless parent.const_defined?(first)
            parent.const_set(first, klass)
          else
            first.constantize
          end
          create_class(other.join('::'), parent, superclass, &block)
        end
      end

      # defines "ModelNameTranslation" if it's not defined manualy
      def define_translation_class name, attrs, options = {}
        klass = name.constantize rescue nil
        adapter = Lolita::DBI::Base.create(self)
        unless klass
          klass = create_class(name, Object, get_orm_class(adapter)) do
            if adapter.dbi.adapter_name == :mongoid
              include Mongoid::Document
            end
            # set's real table name
            translation_adapter = Lolita::DBI::Base.create(self)
            translation_adapter.collection_name = options[:table_name] || adapter.collection_name.to_s.singularize + "_translation"
           
            cattr_accessor :translate_attrs, :master_id

            # before friendly_id 4.x
            if adapter.klass.respond_to?(:uses_friendly_id?) && adapter.klass.send(:uses_friendly_id?)
              parent_config = adapter.klass.friendly_id_config
          
              has_friendly_id parent_config.method,
                :allow_nil => parent_config.allow_nil,
                :approximate_ascii => parent_config.approximate_ascii,
                :ascii_approximation_options => [:russian],
                :max_length => parent_config.max_length,
                :reserved_words => parent_config.reserved_words,
                :use_slug => parent_config.use_slug
            end
            
            # override validate to vaidate only translate fields from master Class
            def validate
              item = self.class.name.sub('Translation','').constantize.new(self.attributes.clone.delete_if{|k,_| !self.class.translate_attrs.include?(k.to_sym)})
              item_adapter = Lolita::DBI::Adapter.add(item.class)
              self_adapter = Lolita::DBI::Adapter.add(self)
              was_table_name = item_adapter.collection_name
              item_adapter.collection_name = self_adapter.collection_name
              item.valid? rescue
              self.class.translate_attrs.each do |attr|
                errors_on_attr = item.errors.on(attr)
                self.errors.add(attr,errors_on_attr) if errors_on_attr
              end
              item_adapter.collection_name = was_table_name
            end
            extend Lolita::TranslationClassMethods

          end
          klass.translate_attrs = attrs
        else
          unless klass.respond_to?(:translate_attrs)
            klass.send(:cattr_accessor, :translate_attrs, :master_id)
            klass.send(:extend,TranslationClassMethods)
            klass.translate_attrs = attrs            
          end
        end
        
        klass.extract_master_id(name)
        klass
      end

      def get_orm_class(adapter)
        adapter.dbi.adapter_name == :active_record ?  ActiveRecord::Base : nil
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

      
      #private is no good

      def find_translation(locale)
        locale = locale.to_s
        translations.detect { |t| t.locale == locale }
      end
    end
  end

  module TranslationClassMethods
    # sets real master_id it's aware of STI
    def extract_master_id name
      master_class = name.sub('Translation','').constantize
      #FIXME why need to check superclass ?
      class_name = master_class.name #!master_class.superclass.abstract_class? ? master_class.superclass.name : master_class.name
      self.master_id = :"#{class_name.demodulize.underscore}_id"
    end
  end
end

