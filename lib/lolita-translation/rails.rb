module LolitaTranslation
  class Engine < Rails::Engine

  end

  class Railtie < Rails::Railtie
    railtie_name :lolita_translation

    rake_tasks do
      load "tasks/lolita_translation.rake"
    end
  end

end

require 'lolita-translation/lolita/component_hooks.rb'