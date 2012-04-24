# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "lolita-translation"
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ITHouse", "Gatis Tomsons", "Arturs Meisters"]
  s.date = "2012-04-24"
  s.description = "Translates models in Lolita"
  s.email = "support@ithouse.lv"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "app/assets/.gitkeep",
    "app/assets/javascripts/.gitkeep",
    "app/assets/javascripts/lolita/translation/application.js",
    "app/assets/stylesheets/lolita/translation/application.css",
    "app/views/components/lolita/translation/_assets.html.erb",
    "app/views/components/lolita/translation/_language_wrap.html.erb",
    "app/views/components/lolita/translation/_switch.html.haml",
    "config/locales/en.yml",
    "config/locales/lv.yml",
    "lib/generators/lolita_translation/USAGE",
    "lib/generators/lolita_translation/has_translations_generator.rb",
    "lib/lolita-translation.rb",
    "lib/lolita-translation/configuration.rb",
    "lib/lolita-translation/model.rb",
    "lib/lolita-translation/modules.rb",
    "lib/lolita-translation/rails.rb",
    "lib/tasks/has_translations_tasks.rake",
    "lolita-translation.gemspec",
    "spec/has_translations_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/ithouse/lolita-translations"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Lolita models translation plugin"
  s.test_files = [
    "spec/has_translations_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<lolita>, [">= 3.2.0.rc.3"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<lolita>, [">= 3.2.0.rc.3"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<lolita>, [">= 3.2.0.rc.3"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

