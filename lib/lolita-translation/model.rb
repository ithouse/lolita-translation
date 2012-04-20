module Lolita
  module Translation
    class ClassFactory

      def self.create(class_name, parent, superclass=nil, &block)
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
          self.create(other.join('::'), parent, superclass, &block)
        end
      end
    end

    module ModelInstanceMethods
      # override validate to vaidate only translate fields from master Class
      def validate
        item = self.class.name.sub('Translation','').constantize.new(self.attributes.clone.delete_if{|k,_| !self.class.translate_attrs.include?(k.to_sym)})
        item_adapter = Lolita::DBI::Base.create(item.class)
        self_adapter = Lolita::DBI::Base.create(self.class)
        was_table_name = item_adapter.collection_name
        item_adapter.collection_name = self_adapter.collection_name
        item.valid? rescue
        self.class.translate_attrs.each do |attr|
          errors_on_attr = item.errors.on(attr)
          self.errors.add(attr,errors_on_attr) if errors_on_attr
        end
        item_adapter.collection_name = was_table_name
      end
    end

    module ModelClassMethods
      # sets real master_id it's aware of STI
      def extract_master_id name
        master_class = name.sub('Translation','').constantize
        #FIXME why need to check superclass ?
        class_name = master_class.name #!master_class.superclass.abstract_class? ? master_class.superclass.name : master_class.name
        self.master_id = :"#{class_name.demodulize.underscore}_id"
      end
    end

    class TranslationModel

      attr_reader :adapter,:klass

      def initialize(config)
        @config = config
        @adapter =  Lolita::DBI::Base.create(@config.klass)
        @klass = begin
          @config.translation_class_name.constantize 
        rescue
          self.create
        end
        fix_class_attrs
        @klass.extract_master_id(@config.translation_class_name)
      end

      def create
        translation_model = self
        config = @config
        new_klass = Lolita::Translation::ClassFactory.create(@config.translation_class_name, Object, get_orm_class) do
            if translation_model.adapter.dbi.adapter_name == :mongoid
              include Mongoid::Document
            end
            # set's real table name
            translation_adapter = Lolita::DBI::Base.create(self)
            translation_adapter.collection_name = config.options[:table_name] || translation_model.adapter.collection_name.to_s + "_translations"
           
            cattr_accessor :translate_attrs, :master_id
            attr_accessible :locale, :text_page_id

            include Lolita::Translation::ModelInstanceMethods
            extend Lolita::Translation::ModelClassMethods
        end
        new_klass.class_eval %(attr_accessible #{@config.attrs.collect{|i| ":#{i}"}.join(',')})
        new_klass.translate_attrs = @config.attrs
        new_klass
      end

      private

      def get_orm_class()
        @adapter.dbi.adapter_name == :active_record ?  ActiveRecord::Base : nil
      end

      def fix_class_attrs
        unless @klass.respond_to?(:translate_attrs)
          @klass.send(:cattr_accessor, :translate_attrs, :master_id)
          @klass.send(:extend,Lolita::Translation::ModelClassMethods)
          @klass.translate_attrs = @config.attrs            
        end
      end
    end
  end
end