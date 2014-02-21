require File.expand_path("lib/lolita-translation/locales")

describe Lolita::Translation::Locales do
  let(:klass){ ::Lolita::Translation::Locales }

  it "should create new with given locales names" do
    obj = klass.new([:lv,:en,:ru])
    obj.locale_names.should eq([:en,:lv,:ru])
  end

  it "should implement Enumerable and each element should be Locale" do
    obj = klass.new([:lv,:en,:ru])
    obj.first.should be_kind_of(Lolita::Translation::Locale)
  end

  it "should return locales in order where first is locale that belongs to record" do
    obj = klass.new([:lv,:en,:ru])
    resource = double("resource")
    transl_rec = double("transl-rec")
    resource.stub(:translation_record).and_return(transl_rec)
    transl_rec.stub(:default_locale).and_return(:ru)
    obj.by_resource_locale(resource).map{|r| r.name}.should eq([:ru,:en,:lv])
  end

  it "should return active locale" do
    obj = klass.new([:lv,:en,:ru])
    I18n.locale = :ru
    obj.active.name.should eq(:ru)
  end
end