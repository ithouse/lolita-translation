require 'header'
require File.expand_path("lib/lolita-translation/record")

describe Lolita::Translation::Record do 
  let(:klass) { Lolita::Translation::Record }

  describe Lolita::Translation::Record::AbstractRecord do 
    let(:abr_klass){ Lolita::Translation::Record::AbstractRecord }
    
    it "should have orm_record attributes" do 
      some_obj = double("some_obj")
      rec = abr_klass.new(some_obj)
      rec.orm_record.should eq(some_obj)
    end

    it "should have #locale" do 
      rec = abr_klass.new(double)
      rec.locale.should eq(::I18n.locale)
    end
  end

  describe Lolita::Translation::Record::ARRecord do 
    let(:ar_klass){ Lolita::Translation::Record::ARRecord }

    it "should return default locale from db if there is field defined or system default locale" do 
      ar_record = double("ar")
      ar_class = double("AR")
      ar_record.stub(:class).and_return(ar_class)
      ar_class.stub(:column_names).and_return(["name","default_locale"])
      ar_record.stub(:attributes).and_return({"default_locale" => :en})
      rec = ar_klass.new(ar_record)
      rec.locale.should eq(:en)
    end

    it "should use default locale when there isn't field for that" do 
      I18n.locale = :lv
      ar_record = double("ar")
      ar_class = double("AR")
      ar_record.stub(:class).and_return(ar_class)
      ar_class.stub(:column_names).and_return(["name"])
      ar_record.stub(:attributes).and_return({"name" => "Name"})
      rec = ar_klass.new(ar_record)
      rec.locale.should eq(:lv)
    end
  end

  it "should have original record" do 
    some_obj = double
    klass.new(some_obj).original_record.should eq(some_obj)
  end

  it "should have default locale" do 
    some_obj = double
    klass.new(some_obj).default_locale.should eq(::I18n.locale)
  end

  it "should build nested translations" do 
    ::I18n.available_locales = [:lv,:ru]
    I18n.locale = :lv
    rec = double("record")
    rec.stub(:id).and_return(1)

    translations = double("translations")
    translations.should_receive(:build).with({:locale => "ru", :record_id => 1})
    rec.stub(:translations).and_return(translations)

    obj = klass.new(rec)
    obj.orm_wrapper.stub(:association_key).and_return(:record_id)
    obj.build_nested_translations
  end

end