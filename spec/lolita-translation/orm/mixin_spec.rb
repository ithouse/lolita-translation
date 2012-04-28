require 'header'
require File.expand_path("lib/lolita-translation/orm/mixin")
require File.expand_path("lib/lolita-translation/errors")

describe Lolita::Translation::ORM do  
  let(:klass){ Class.new }

  before(:each) do 
    klass.extend(Lolita::Translation::ORM::ClassMethods)
    klass.class_eval do 
      include Lolita::Translation::ORM::InstanceMethods
    end
  end

  context "ClassMethods" do 

    it "should provide #translate method to class" do 
      klass.should respond_to(:translate)
    end

    it "should provide #translations_configuration for class" do 
      klass.should respond_to(:translations_configuration)
    end 

    it "should raise error when configuration is requested before its initialization" do 
      expect{
        klass.translations_configuration
      }.to raise_error(Lolita::Translation::ConfigurationNotInitializedError)
    end 

    it "should provide #sync_translation_table!" do 
      klass.should respond_to(:sync_translation_table!)
    end  
  end

  context "InstanceMethods" do 
    it "should provide #translation_record to all instances of class" do 
      obj = klass.new
      obj.should respond_to(:translation_record)
    end 

    it "should provide #original_locale" do 
      obj = klass.new
      obj.should respond_to(:original_locale)
    end
  end
end