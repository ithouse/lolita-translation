require File.expand_path("lib/lolita-translation/locale")

describe Lolita::Translation::Locale do 
  let(:klass){ Lolita::Translation::Locale }

  it "should create new with given locale name" do 
    obj = klass.new(:lv)
    obj.name.should eq(:lv)
    obj.short_name.should eq(:lv)
  end

  it "should have humanized name" do 
    obj = klass.new(:lv)
    obj.humanized_short_name.should eq("Lv")
  end

  it "should detect locale is active" do 
    obj = klass.new(:lv)
    I18n.locale = :en 
    obj.should_not be_active
    I18n.locale = :lv 
    obj.should be_active
  end
end