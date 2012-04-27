require 'header'
require 'ar_schema'
require File.expand_path("lib/lolita-translation/builder/active_record_builder")

describe Lolita::Translation::Builder::ActiveRecordBuilder do 
  let(:klass) { Lolita::Translation::Builder::ActiveRecordBuilder }
  before(:each) do 
    a_klass = Class.new(ActiveRecord::Base)
    Object.const_set(:Product, a_klass)
  end

  after(:each) do 
    Object.send(:remove_const, :Product) rescue nil
  end

 
  it "should build class with ActiveRecord::Base as superclass" do 
    obj = klass.new(Product)
    obj.build_klass
    obj.klass.superclass.should eq(ActiveRecord::Base)
  end

  it "should call class methods on klass" do 
    obj = klass.new(Product)
    obj.build_klass
    obj.call_klass_class_methods
    obj.klass.reflections.keys.should include(:product)
  end

  it "should update base class" do
    obj = klass.new(Product)
    obj.build_klass
    obj.update_base_klass
    Product.reflections.keys.should include(:translations)
  end 
end