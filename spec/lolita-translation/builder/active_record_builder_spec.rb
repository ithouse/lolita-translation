require 'header'
require 'ar_schema'
require File.expand_path("lib/lolita-translation/builder/active_record_builder")
require File.expand_path("lib/lolita-translation/configuration")
ARSchema.connect!

describe Lolita::Translation::Builder::ActiveRecordBuilder do 
  let(:klass) { Lolita::Translation::Builder::ActiveRecordBuilder }
  let(:config){ Lolita::Translation::Configuration.new(Product) }
  before(:each) do 
    Object.send(:remove_const, :Product) if Object.const_defined?(:Product)
    a_klass = Class.new(ActiveRecord::Base)
    Object.const_set(:Product, a_klass)
  end

  after(:each) do 
    Object.send(:remove_const, :Product) rescue nil
  end

 
  it "should build class with ActiveRecord::Base as superclass" do 
    obj = klass.new(Product)
    obj.build
    obj.klass.superclass.should eq(ActiveRecord::Base)
  end

  it "should call class methods on klass" do 
    obj = klass.new(Product, config)
    obj.stub(:association_name).and_return(:product)
    obj.build
    obj.klass.reflections.keys.should include(:product)
  end

  it "should update base class" do
    obj = klass.new(Product,config)
    obj.stub(:translations_association_name).and_return(:translations)
    obj.build
    Product.reflections.keys.should include(:translations)
  end 
end