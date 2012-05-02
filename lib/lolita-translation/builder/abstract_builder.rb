module Lolita
  module Translation
    module Builder

      class AbstractBuilder
        attr_reader :base_klass, :klass, :configuration

        def initialize(base_class, configuration = nil, superclass = nil)
          @superclass     = superclass
          @base_klass     = base_class
          @configuration  = configuration
          @klass          = create_klass
        end

        def class_name
          "#{@base_klass.to_s}Translation"
        end

        def build
          implementation_warn
        end

        def association_name
          @configuration && @configuration.demodulized_class_name
        end

        def association_key
          @configuration && @configuration.association_key
        end

        def translations_association_name
          @configuration && @configuration.association_name
        end

        def locale_field_name
          @configuration && @configuration.locale_field_name
        end

        def table_name
          @configuration && @configuration.table_name
        end

        def override_klass_attributes method_names
          method_names.each do |method_name, attribute|
            validate_attribute_method_and_attribute(method_name, attribute)
            base_klass.instance_eval do 
              define_method(method_name) do 
                translation_record.attribute(attribute)
              end
            end
          end
        end 

        private

        def configuration_attributes
          @configuration && @configuration.attributes
        end

        def validate_attribute_method_and_attribute(method_name, attribute)
          raise ArgumentError.new("#{method_name} is not valid attribute reader name") unless method_name
          raise ArgumentError.new("#{attribute} is not valid attribute name") unless attribute 
        end

        def implementation_warn
          warn("No implementation for #{self}")
        end

        def create_klass
          new_klass = Class.new(@superclass || Object)
          link_klass_with_constant(new_klass)
          new_klass
        end

        def link_klass_with_constant(new_klass)
          unless new_klass.name == self.class_name
            name_parts = class_name.split("::")
            new_class_name = name_parts.pop
            parent_object = find_parent_object(Object,name_parts)
            assign_class_to_constant(parent_object,new_class_name, new_klass)
          end
        end

        def assign_class_to_constant parent_object, new_class_name, new_klass
          new_class_name = new_class_name.to_sym
          if parent_object.const_defined?(new_class_name)
            parent_object.send(:remove_const,new_class_name)
          end
          parent_object.const_set(new_class_name.to_sym, new_klass)
        end

        def find_parent_object parent_object, name_parts
          name_parts.each do |const_name|
            parent_object = parent_object.const_get(const_name.to_sym)
          end
          parent_object
        end

      end

    end
  end
end 