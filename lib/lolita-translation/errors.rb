module Lolita
  module Translation
    class ConfigurationNotInitializedError < StandardError
      def initialize(klass)
        super %Q{Configuration is not initialized for #{klass}. Try to call #translate in class.}
      end
    end

    class NoBuilderForClassError < ArgumentError
      def initialize(klass)
        super %Q{No builder for #{klass}. See available builder in /lib/lolita-translation/builder directory.}
      end
    end 
  end
end