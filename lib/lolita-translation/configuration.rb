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
        @config ||= Lolita::Translation::Configuration.new(self,*attrs)
      end
    end

    class Configuration

      attr_reader :klass, :options, :translation_class_name, :translation_class,:attrs

      def initialize(base_class, *attrs)
        @klass = base_class
        @attrs = attrs
        initialize_options
        include_modules
        initialize_default_attributes
        extend_klass
        extend_translation_class
      end

      private

      def extend_klass
        config = self
        @klass.class_eval do
    
          class_attribute :has_translations_options
          self.has_translations_options = config.options

          class_attribute :columns_has_translations
          self.columns_has_translations = (columns rescue []).collect{|col| col if config.attrs.include?(col.name.to_sym)}.compact
          
          class_attribute :translation_attrs
          self.translation_attrs = config.attrs

          has_many :translations, :class_name => config.translation_class_name, :foreign_key => config.translation_class.master_id, :dependent => :destroy
          accepts_nested_attributes_for :translations, :allow_destroy => true, :reject_if => proc { |attributes| columns_has_translations.collect{|col| attributes[col.name].blank? ? nil : 1}.compact.empty? }
          
          scope :translated, lambda { |locale| 
            where("#{translation_class.table_name}.locale = ?", locale.to_s).joins(:translations)
          }

          class << self
            alias_method_chain :find, :translations
          end
        end
        override_readers
      end

      def extend_translation_class
        translation_class.belongs_to @klass.name.demodulize.underscore.to_sym
        translation_class.validates_presence_of :locale
        translation_class.validates_uniqueness_of :locale, :scope => translation_class.master_id
      end

      def override_readers
        if options[:reader]
          attrs.each do |name|
            override_reader(name)
          end
        end
      end

      def override_reader(name)
        @klass.send :define_method, name do
          unless ::I18n.default_locale == ::I18n.locale
            translation = self.translation(::I18n.locale)
              if translation.nil?
                if has_translations_options[:fallback]
                  (self[name].nil? || self[name].blank?) ? has_translations_options[:nil] : self[name].set_origins(self,name)                    else
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

      def initialize_default_attributes
        @translation_class_name = "#{@klass.name}Translation"
        @translation_class = Lolita::Translation::TranslationModel.new(self).klass
      end

      def include_modules
        @klass.send(:include, Lolita::Translation::InstanceMethods)
        @klass.extend(Lolita::Translation::ClassMethods)
      end

      def initialize_options
        @options = {
          :fallback => true,
          :reader => true,
          :writer => false,
          :nil => ''
        }.merge(@attrs.extract_options!)
        @options.assert_valid_keys([:fallback, :reader, :writer, :nil,:table_name])
      end

    end
  end
end