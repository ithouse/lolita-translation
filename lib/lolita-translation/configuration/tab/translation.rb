module Lolita
  module Configuration
    module Tab
      class Translation < Lolita::Configuration::Tab::Base

        def initialize(dbi,*args,&block)
          @type=:translation
          super
        end
        
      end
    end
  end
end