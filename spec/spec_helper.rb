# encoding: utf-8
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'active_record'
require 'active_support'
require 'logger'
require 'ffaker'
require File.expand_path('lib/lolita-translation')

ActiveRecord::Base.logger = Logger.new(File.open("#{File.dirname(__FILE__)}/database.log", 'w+'))
ActiveRecord::Base.establish_connection({ :database => ":memory:", :adapter => 'sqlite3', :timeout => 500 })

# setup I18n
I18n.available_locales = [:en,:lv,:ru,:fr]
I18n.default_locale = :en
I18n.locale = :en

# Add models
ActiveRecord::Schema.define do
  create_table :news, :force => true do |t|
    t.string :title
    t.string :slug
    t.text :body
    t.integer :category_id
    t.integer :trx_id
  end
  create_table :categories, :force => true do |t|
    t.string :name
    t.string :desc
    t.integer :trx_id
  end
  create_table :groups, :force => true do |t|
    t.string :name
  end
  create_table :categories_groups, :force => true, :id => false do |t|
    t.integer :category_id
    t.integer :group_id
  end
  create_table :meta_datas, :force => true do |t|
    t.string :title
    t.string :url
    t.string :keywords
    t.text :description
    t.string :metaable_type
    t.integer :metaable_id
  end
end

class News < ActiveRecord::Base
  include Lolita::Translation
  belongs_to :category, :dependent => :destroy
  has_one :meta_data, :as => :metaable, :dependent => :destroy
  translations :title, :body
end

class Category < ActiveRecord::Base
  include Lolita::Translation
  has_many :news
  has_and_belongs_to_many :groups
  translations :name
end

class Group < ActiveRecord::Base
  include Lolita::Translation
  has_and_belongs_to_many :categories
  translations :name
end

class MetaData < ActiveRecord::Base
  set_table_name :meta_datas
  include Lolita::Translation
  belongs_to :metaable, :polymorphic => true
  translations :title, :url, :keywords, :description
end

# build translation tables

News.sync_translation_table!
Category.sync_translation_table!
Group.sync_translation_table!
MetaData.sync_translation_table!

# this is included in Lolita by default
class ::Hash
  # converts all keys to symbols, but RECURSIVE
  def symbolize_keys!
    each do |k,v|
      sym = k.respond_to?(:to_sym) ? k.to_sym : k
      self[sym] = Hash === v ? v.symbolize_keys! : v
      delete(k) unless k == sym
    end
    self
  end
end
RSpec.configure do |config|
  config.before(:each) do
    News.delete_all
    Category.delete_all
    MetaData.delete_all
  end
end
