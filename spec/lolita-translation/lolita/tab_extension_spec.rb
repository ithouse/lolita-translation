require 'spec_helper'
ARSchema.connect!

describe "Lolita tab extension" do 
  let(:some_class){ Class.new }
  let(:dbi) do 
    tdbi = double("dbi") 
    tdbi.stub(:klass).and_return(some_class)
    tdbi
  end

  it "should provide tab with #translatable? method" do 
    Lolita::Translation::Configuration.any_instance.stub(:build_translation_class).and_return(true)
    tab = Lolita::Configuration::Tab::Base.new(dbi, :default)
    tab.send(:translation_tab_extension).stub(:collect_possibly_translateble_fields).and_return([:name, :body])
    tab.should_not be_translatable
    some_class.class_eval do 
      include Lolita::Translation
      translate :name, :body
    end
    tab.should be_translatable
  end

  it "should provide tab with #build_translations_nested_form with resource" do 
    c_class = Class.new(ActiveRecord::Base)
    Object.const_set(:Product,c_class)
    c_class.class_eval do 
      include Lolita::Configuration
      include Lolita::Translation
      translate :name
      lolita
    end
    tab = Lolita::Configuration::Tab::Base.new(Lolita::DBI::Base.create(Product), :default)
    category = Product.new
    form = tab.build_translations_nested_form(category)
    category.translations.should have(I18n.available_locales.size - 1).items
    form.fields.should have(1).item
  end
end 