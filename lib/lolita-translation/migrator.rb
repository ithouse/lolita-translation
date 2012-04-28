module Lolita
  module Translation
    
    class Migrator

      attr_reader :klass,:config

      def initialize(base_class)
        @klass  = base_class
        @config = @klass.translations_configuration 
      end

      def migrate
        raise StandardError, "#{self.class} must implement this method"
      end

      class << self
        def create(klass)
          if active_record?(klass)
            Lolita::Translation::Migrators::ActiveRecordMigrator.new(klass)
          elsif mongoid?(klass)
            Lolita::Translation::Migrators::MongoidMigrator.new(klass)
          end
        end

        private

        def active_record?(klass)
          Lolita::Translation::Utils.active_record_class?(klass)
        end

        def mongoid?(klass)
          Lolita::Translation::Utils.mongoid_class?(klass)
        end
      end

      private

      def switch_stdout
        begin
          out = StringIO.new
          $stdout = out
          yield
        ensure
          $stdout = STDOUT
        end
      end

    end

  
  end
end

require 'lolita-translation/migrators/active_record_migrator'
require 'lolita-translation/migrators/mongoid_migrator'