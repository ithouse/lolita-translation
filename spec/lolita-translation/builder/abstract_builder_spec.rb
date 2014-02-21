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
    set_class_name(some_class)
    klass.new(some_class).base_klass.should eq(some_class)
  end

  it "should return new class name like <ClassName>Translation for class named 'ClassName' " do 
    set_class_name(some_class)
    klass.new(some_class).class_name.should eq("SomeClassTranslation")
  end

  it "should return class name like <Scoped::ClassName>Translation for class name 'Scoped::ClassName'" do 
    stub_const('Scoped',Class.new)
    set_class_name(some_class,"Scoped::ClassName")
    klass.new(some_class).class_name.should eq("Scoped::ClassNameTranslation")
  end

  it "should create class with scoped name" do 
    stub_const('Scoped',Class.new)
    set_class_name(some_class,"Scoped::OtherClassName")
    klass.new(some_class).klass.name.should eq("Scoped::OtherClassNameTranslation")
  end

  it "should show warning when method that should be implemented in concrete builder is not implemented yet" do 
    set_class_name(some_class)
    ab_builder = klass.new(some_class)
    expect{
      ab_builder.build
    }.not_to raise_error
    ab_builder.should_receive(:implementation_warn).once
    ab_builder.build
  end

  it "should create new class on initialization" do 
    set_class_name(some_class)
    klass.new(some_class).klass.to_s.should eq("SomeClassTranslation")
  end

  it "should accept superclass as third argument for new" do
    set_class_name(some_class)
    superclass = Class.new
    builder = klass.new(some_class,nil,superclass)
    builder.klass.superclass.should eq(superclass)
  end
end