require 'header'
require File.expand_path("lib/lolita-translation/builder/abstract_builder")

describe Lolita::Translation::Builder::AbstractBuilder do 
  let(:klass){ Lolita::Translation::Builder::AbstractBuilder }
  let(:some_class){ Class.new }

  def set_class_name(klass, name = "SomeClass") 
    klass.singleton_class.instance_eval do 
      define_method(:to_s) do 
        name
      end
    end
  end

  it "should have @base_klass attribute" do 
    klass.new(some_class).base_klass.should eq(some_class)
  end

  it "should return new class name like <ClassName>Translation for class named 'ClassName' " do 
    set_class_name(some_class)
    klass.new(some_class).class_name.should eq("SomeClassTranslation")
  end

  it "should return class name like <Scoped::ClassName>Translation for class name 'Scoped::ClassName'" do 
    set_class_name(some_class,"Scoped::ClassName")
    klass.new(some_class).class_name.should eq("Scoped::ClassNameTranslation")
  end

  it "should create class with scoped name" do 
    Object.const_set(:Scoped,Class.new)
    set_class_name(some_class,"Scoped::OtherClassName")
    klass.new(some_class).create_klass
  end

  it "should show warning when method that should be implemented in concrete builder is not implemented yet" do 
    ab_builder = klass.new(some_class)
    expect{
      ab_builder.build_klass
    }.not_to raise_error
    ab_builder.should_receive(:implementation_warn).exactly(3).times
    ab_builder.build_klass
    ab_builder.call_klass_class_methods
    ab_builder.update_base_klass
  end

  it "should have #create_klass that create new empty class with class name" do 
    set_class_name(some_class)
    klass.new(some_class).create_klass.to_s.should eq("SomeClassTranslation")
  end

  it "#create_klass should accept superclass as optional argument" do 
    set_class_name(some_class)
    builder = klass.new(some_class)
    super_class = Class.new
    builder.create_klass(super_class)
    builder.klass.superclass.should eq(super_class)
  end
end