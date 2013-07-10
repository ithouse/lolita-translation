require 'spec_helper'

describe Lolita::Translation::Migrator do
  let(:klass) { Lolita::Translation::Migrator }

  before(:each) do
    c_class = Class.new(ActiveRecord::Base)
    stub_const('Comment',c_class)
    c_class.class_eval do
      include Lolita::Translation
      translate :body
    end
  end

  describe "Instance methods" do

    it "should have klass and config attributes" do
      migrator = klass.new(Comment)
      migrator.klass.should eq(Comment)
      migrator.config.should eq(Comment.translations_configuration)
    end

    it "should raise error when #migrate called" do
      migrator = klass.new(Comment)
      expect{
        migrator.migrate
      }.to raise_error(StandardError)
    end
  end

  describe "Class methods" do
    it "should create concrete migrator for AR" do
      klass.create(Comment).should be_kind_of(Lolita::Translation::Migrators::ActiveRecordMigrator)
    end
  end

end