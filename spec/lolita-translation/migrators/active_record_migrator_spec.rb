require 'spec_helper'
require 'ar_schema'
ARSchema.connect!

describe Lolita::Translation::Migrators::ActiveRecordMigrator do 
  let(:klass){ Lolita::Translation::Migrators::ActiveRecordMigrator }

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

  it "should create new table for class" do 
    migrator = klass.new(Comment)
    ActiveRecord::Base.connection.tables.should_not include("comments_translations")
    migrator.migrate
    ActiveRecord::Base.connection.tables.should include("comments_translations")
    CommentTranslation.column_names.sort.should eq(%w(body locale comment_id id).sort)
  end

  it "should add new column to table when one is added to configuration" do 
    migrator = klass.new(Comment)
    ActiveRecord::Base.connection.tables.should_not include("comments_translations")
    migrator.migrate
    CommentTranslation.column_names.sort.should eq(%w(body locale comment_id id).sort)
    Comment.translations_configuration.attributes << :commenter
    migrator.migrate
    CommentTranslation.column_names.sort.should eq(%w(body locale comment_id id commenter).sort)
  end

  it "should remove column from table if it is removed from configuration" do 
     migrator = klass.new(Comment)
    Comment.translations_configuration.attributes << :commenter
    migrator.migrate
    CommentTranslation.column_names.sort.should eq(%w(body locale comment_id id commenter).sort)
    Comment.translations_configuration.attributes.pop
    migrator.migrate
    CommentTranslation.column_names.sort.should eq(%w(body locale comment_id id).sort)
  end
end