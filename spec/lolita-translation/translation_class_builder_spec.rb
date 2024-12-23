require File.expand_path("lib/lolita-translation/translation_class_builder")
require File.expand_path("lib/lolita-translation/errors")
require 'ar_schema'

describe Lolita::Translation::TranslationClassBuilder do 
  let(:klass){ Lolita::Translation::TranslationClassBuilder }
  let(:some_class){ Class.new }

  it "should have @klass attribute" do 
    klass.new(some_class).klass.should eq(some_class)
  end

  context "ActiveRecord" do 
    let(:ar_klass){ Lolita::Translation::Builder::ActiveRecordBuilder }

    def stub_create_klass
      ar_klass.any_instance.stub(:create_klass).and_return(true)
    end

    it "should validate if there are concrete builder availabe" do 
      klass.new(some_class).builder_available?.should be_falsey
      klass.new(Class.new(ActiveRecord::Base)).builder_available?.should be_truthy
    end

    it "should have builder when there is builder class available" do 
      stub_create_klass
      klass.new(some_class).builder.should be_nil
      klass.new(Class.new(ActiveRecord::Base)).builder.should be_kind_of(Lolita::Translation::Builder::ActiveRecordBuilder)
    end

    it "should raise error when #build_class is called for unsupported builder" do 
      expect{
        obj = klass.new(some_class)
        obj.build_class
      }.to raise_error(Lolita::Translation::NoBuilderForClassError)
    end

    it "should override attributes to base class" do 
      stub_create_klass
      obj = klass.new(Class.new(ActiveRecord::Base))
      obj.builder.should_receive(:override_klass_attributes)
      obj.override_attributes :name
    end

    it "should raise error when no builder to use for #override_attributes" do 
      stub_create_klass
      obj = klass.new(some_class)
      expect{
        obj.override_attributes :name
      }.to raise_error(Lolita::Translation::NoBuilderForClassError)
    end

    it "should build concrete class when #build is called" do 
      stub_create_klass
      obj = klass.new(Class.new(ActiveRecord::Base))
      obj.builder.should_receive(:build).and_return(true)
      obj.build_class
    end
  end

end
