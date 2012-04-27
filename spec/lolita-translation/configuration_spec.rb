require 'header'
require File.expand_path("lib/lolita-translation/configuration")
require File.expand_path("lib/lolita-translation/translation_class_builder")
require File.expand_path("lib/lolita-translation/errors")

describe Lolita::Translation::Configuration do 
  let(:klass){Lolita::Translation::Configuration}
  let(:some_class){Class.new}

  before(:each) do 
    Lolita::Translation::TranslationClassBuilder.any_instance.stub(:build_class).and_return("builder")
    Lolita::Translation::TranslationClassBuilder.any_instance.stub(:override_attributes).and_return("attributes")
  end

  it "should have @klass attribute" do 
    klass.new(some_class).klass.should eq(some_class)
  end

  it "should have @attributes attribute" do 
    klass.new(some_class, :name, :body).attributes.sort.should eq([:name,:body].sort)
  end

  it "should have @translation_class attribute" do 
    Object.const_set(:Product,some_class)
    klass.new(some_class).translation_class.should eq("builder")
  end

  it "should yield block with self when called with block" do 
    block_called = nil
    translation_conf = klass.new(some_class) do |conf|
      block_called = conf
    end
    block_called.should eq(translation_conf)
  end
end