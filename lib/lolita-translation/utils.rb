module Lolita
  module Translation
    module Utils
      def self.mongoid_class?(klass) 
        defined?(Mongoid::Document) && klass.ancestors.include?(Mongoid::Document)
      end

      def self.active_record_class?(klass)
         defined?(ActiveRecord::Base) && klass.ancestors.include?(ActiveRecord::Base)
      end
    end
  end
end