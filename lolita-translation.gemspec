# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lolita-translation/version"

Gem::Specification.new do |s|
  s.name        = "lolita-translation"
  s.version     = Lolita::Translation::Version.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["ITHouse (Latvia) and Arturs Meisters"]
  s.email       = "support@ithouse.lv"
  s.homepage    = "http://github.com/ithouse/lolita-translation"
  s.summary     = %q{Lolita extension that add multilanguate support to Lolita.}
  s.description = %q{Lolita extension that allow users to change language and translate DB data.}

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.licenses = ["MIT"]

  s.add_runtime_dependency(%q<lolita>, [">= 3.2"])
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
end
