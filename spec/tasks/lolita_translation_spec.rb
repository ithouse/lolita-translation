require 'spec_helper'
require 'ar_schema'
ARSchema.connect!

describe "lolita_translation:sync_tables" do
  def translations
    ActiveRecord::Base.connection.tables.reject{|tn| !tn.match(/translations/)}.sort
  end

  before(:each) do
    c_class = Class.new(ActiveRecord::Base)
    stub_const('Comment',c_class)
    c_class.class_eval do
      include Lolita::Translation
      translate :body
    end
    ActiveRecord::Base.connection.execute("DROP TABLE comments_translations") rescue nil
  end

  it "should create translation tables for all lolita mappings" do
    translations.should eq(%w(categories_translations posts_translations products_translations).sort)
    Lolita.mappings[:comment] = Lolita::Mapping.new(:comments)
    load(File.expand_path("lib/tasks/lolita_translation.rake"))
    Rake.application["lolita_translation:sync_tables"].invoke()
    translations.should eq(%w(categories_translations posts_translations comments_translations products_translations).sort)
  end
end