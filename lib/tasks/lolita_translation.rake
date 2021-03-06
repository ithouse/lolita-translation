require 'lolita-translation'
require 'rake'

task :environment

namespace :lolita_translation do
  desc "Synca all tables at once"
  task sync_tables: :environment do
    Lolita.mappings.each do |k,mapping|
      klass = mapping.to
      if klass && klass.respond_to?(:sync_translation_table!)
        klass.sync_translation_table!
      end
    end
  end
end
