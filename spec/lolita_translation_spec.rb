require 'header'
require File.expand_path("lib/lolita-translation")

describe Lolita::Translation do 
  it "configuration is loded" do 
    defined?(Lolita::Translation::Configuration).should_not be_nil
  end

  it "translation class builder is loaded" do 
    defined?(Lolita::Translation::TranslationClassBuilder).should_not be_nil
  end

  it "orm mixin is loaded" do 
    defined?(Lolita::Translation::ORM).should_not be_nil
  end
end