require 'header'
require File.expand_path("lib/lolita-translation/configuration")
require File.expand_path("lib/lolita-translation/translation_class_builder")
require File.expand_path("lib/lolita-translation/errors")

describe Lolita::Translation::Configuration do
  let(:klass){Lolita::Translation::Configuration}
  let(:some_class) do
    Class.new do
      class << self
        def table_exists?
          true
        end
      end
    end
  end

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
    stub_const('Product',some_class)
    klass.new(some_class).translation_class.should eq("builder")
  end

  describe "locales" do
    before do
      stub_const('Product',some_class)
      stub_const('Lolita::Translation::Locales', Class.new) unless defined?(Lolita::Translation::Locales)
    end

    it "can be received as option" do
      Lolita::Translation::Locales.should_receive(:new).with([:en,:ru]).and_return([:en,:ru])
      config = klass.new(some_class, :locales => [:en, :ru])
      config.locales.should == [:en,:ru]
    end

    it "should fall back to Lolita::Translation.locales when no locales are passed" do
      config = klass.new(some_class)
      Lolita::Translation.stub(:locales).and_return([:lv,:ru])
      config.locales.should eq(Lolita::Translation.locales)
    end

    it "can be as anonymous method" do
      Lolita::Translation::Locales.should_receive(:new).and_return([:lv,:ru])
      config = klass.new(some_class, :locales => Proc.new{ [:lv,:ru] })
      config.locales.should eq([:lv,:ru])
    end
  end

  it "should yield block with self when called with block" do
    block_called = nil
    translation_conf = klass.new(some_class) do |conf|
      block_called = conf
    end
    block_called.should eq(translation_conf)
  end
end