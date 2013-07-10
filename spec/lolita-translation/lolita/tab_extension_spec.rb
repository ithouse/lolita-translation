require 'spec_helper'
ARSchema.connect!

describe "Lolita tab extension" do 
  let(:some_class) do 
    Class.new do 
      class << self
        def table_exists?
          true
        end 
      end
    end
  end

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
    stub_const('Product',c_class)
    c_class.class_eval do 
      include Lolita::Configuration
      include Lolita::Translation
      translate :name
      lolita
    end
    tab = Lolita::Configuration::Tab::Base.new(Lolita::DBI::Base.create(Product), :default)
    category = Product.new
    form = tab.build_translations_nested_form(category)
    category.translations.should have(c_class.translations_configuration.locales.locale_names.size - 1).items
    form.fields.should have(1).item
  end

  it "should add #original_locale field to original tab" do 
    c_class = Class.new(ActiveRecord::Base)
    stub_const('Product',c_class)
    c_class.class_eval do 
      include Lolita::Configuration
      include Lolita::Translation
      translate :name
      lolita
    end
    tab = c_class.lolita.tabs.first
    tab.fields.detect{|f| f.name == :original_locale}.should_not be_nil
  end
end 