require 'spec_helper'
require 'ar_schema'

ARSchema.connect!

describe "Integration with ActiveRecord" do 
  before(:each) do 
    ActiveRecord::Base.connection.execute("DELETE FROM categories")
    ActiveRecord::Base.connection.execute("DELETE FROM products")
  end
  context "configuration defination" do 

    before(:each) do 
      Object.send(:remove_const, :Product) rescue nil
      klass = Class.new(ActiveRecord::Base)
      Object.const_set(:Product,klass)
    end

    it "should have class method for translation configuration" do 
      Product.class_eval do
        include Lolita::Translation
      end

      Product.should.respond_to?(:translations)
      Product.should.respond_to?(:translate)
    end

    it "should create configuration when class is loaded with field names to translate" do  
      Product.class_eval do 
        include Lolita::Translation
        translate :name, :description
      end
      Product.translations_configuration.should be_kind_of(Lolita::Translation::Configuration)
    end

    it "should accept block and yield configuration" do 
      block_called = false
      Product.class_eval do 
        include Lolita::Translation
        translate :name, :description do |conf|
          block_called = true
        end
      end
      block_called.should be_true
    end
  end

  context "record" do 
    let(:category){Category.create(:name => "category_name", :default_locale => "en")}

    before(:each) do 
      Object.send(:remove_const, :Category) rescue nil
      klass = Class.new(ActiveRecord::Base)
      Object.const_set(:Category,klass)
      Category.class_eval do 
        include Lolita::Translation
        translate :name
      end
    end

    it "validation should fail when no location is given, but class accepts translation locale" do 
      category = Category.create(:name => Faker::Name.first_name)
      category.errors.keys.should include(:default_locale)
    end

    it "should have default locale" do 
      category = Category.create(:name => Faker::Name.first_name, :default_locale => "en")
      I18n.default_locale = :lv
      category.original_locale.should eq("en")
    end

    it "should have translations" do 
      category.translations.should be_empty
      category.update_attributes(:name => "updated",:translations_attributes => [{:name => "translation-lv", :locale => "lv"}])
      category.errors.should be_empty
      category.translations.reload.should have(1).item
    end

    it "should return translatable attribute in current locale" do 
      I18n.default_locale = :lv
      I18n.locale = :lv
      category.name.should eq("category_name")
      I18n.locale = :en
      category.name.should eq("category_name")
      category.update_attributes(:name => "updated",:translations_attributes => [{:name => "translation-lv", :locale => "lv"}])
      I18n.locale = :lv
      category.name.should eq("translation-lv")
      I18n.locale = :ru 
      category.name.should eq("updated")
    end

    it "should switch attribute to different locale" do 
      category.name.should eq("category_name")
      category.update_attributes(:translations_attributes => [{:name => "translation-lv", :locale => "lv"}])
      category.name.in(:lv).should eq("translation-lv")
    end
  end
  
  context "saving" do
    let(:category){Category.create(:name => "category_name", :default_locale => :en)}
    let(:product){ Product.create(:name => "product_name", :description => "product_description") }

    before(:each) do 
      Object.send(:remove_const, :Category) rescue nil
      Object.send(:remove_const, :Product) rescue nil
      klass = Class.new(ActiveRecord::Base)
      Object.const_set(:Category,klass)
      product_klass = Class.new(ActiveRecord::Base)
      Object.const_set(:Product,product_klass)
      Category.class_eval do 
        include Lolita::Translation
        translate :name
      end
      Product.class_eval do 
        include Lolita::Translation
        translate :name, :description
      end
    end
 
    it "should create translations for object" do 
      new_cat = Category.create({
        :name => "cat_name",
        :original_locale => :en,
        :translations_attributes => [
          {:name => "translation-lv", :locale => "lv"},
          {:name => "translation-fr", :locale => "fr"}
        ]
      })
      new_cat.errors.should be_empty
      new_cat.translations.should have(2).items
    end

    it "should save translation as nested attributes" do 
      category.translations.should be_empty
      category.update_attributes(:translations_attributes => [
        {:name => "translation-lv", :locale => "lv"},
        {:name => "translation-fr", :locale => "fr"}
      ])
      category.translations.reload
      category.translations.should have(2).items
    end

    it "should save locale for record if it accepts it" do 
      I18n.locale = :lv
      category.original_locale.should eq(:en)
      product.original_locale.should eq(:lv)
    end

    it "should not save translation for record default locale" do
      category.translations.should be_empty
      category.update_attributes(:translations_attributes => [
        { :name => "translation2-lv", :locale => "lv"},
        { :name => "translation2-en", :locale => "en"}
      ])
      category.errors.keys.should include(:"translations.locale")
    end

    it "translation record should be associated with original record" do 
      transl1 = CategoryTranslation.new(:name => "translation-lv", :locale => "lv")
      transl1.category = category
      transl1.save
      transl1.errors.should be_empty
      transl2 = CategoryTranslation.create(:name => "translation-fr", :locale => "fr")
      transl2.update_attributes(:name => "updated-translation-fr")
      transl2.errors.keys.should include(:"category")
    end

    it "should validate that locale is presented" do 
      transl1 = CategoryTranslation.new(:name => "translation-lv")
      transl1.category = category 
      transl1.save
      transl1.errors.keys.should eq([:"locale"])
    end

    it "should validate that locale is unique for each original record" do 
      transl1 = category.translations.create(:name => "translation-lv", :locale => "lv")
      transl2 = category.translations.create(:name => "translation-lv", :locale => "lv")
      transl1.errors.should be_empty
      transl2.errors.keys.should eq([:"locale"])
    end
  end

  context "migrating" do 
    before(:each) do 
      Object.send(:remove_const,:Comment) rescue nil
      c_class = Class.new(ActiveRecord::Base)
      Object.const_set(:Comment,c_class)
      c_class.class_eval do 
        include Lolita::Translation
        translate :body
      end
      ActiveRecord::Base.connection.execute("DROP TABLE comments_translations") rescue nil
    end

    after(:each) do 
      Object.send(:remove_const,:Comment) rescue nil
    end

    it "should sync translation table through migrations" do 
      ActiveRecord::Base.connection.tables.should_not include("comments_translations")
      Comment.sync_translation_table!
      ActiveRecord::Base.connection.tables.should include("comments_translations")
    end
  end
end