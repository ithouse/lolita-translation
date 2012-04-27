require 'active_record'

# Override connection method, to load schema on demand when there is no tables in, this allow to solve problems 
# when there are different connection between rspec and capybara::session. This does not work well when data is stored
# in memory, because connection is lost in some way.
class ActiveRecord::Base
  def self.connection 
    temp_c = retrieve_connection
    if temp_c.tables.empty? && !::ARSchema.loading
      ::ARSchema.load_schema
    end
    temp_c
  end
end 

# Is used to load schema and clean data from table when there is any. 
# Schema load is called from overrided ActiveRecord::Base.connection method.
class ARSchema
  cattr_accessor :loading, :connection
  @@loading = false
  @connection = false

  def self.connect!
    unless ActiveRecord::Base.connected?
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    end
  end

  def self.clean!
    [:products,:products_translations,:categories,:categories_translations, :posts, :posts_translations].each do |table_name|
      begin 
        if ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{table_name}")[0]["count(*)"] > 0
          ActiveRecord::Base.connection.execute("DELETE FROM #{table_name}")
        end
      rescue Exception => e
        puts "Error: #{e}"
      end
    end
  end

  def self.load_schema
    # Add models
    ActiveRecord::Schema.define do
      ::ARSchema.loading = true
      create_table :products, :force => true do |t|
        t.string  :name
        t.text    :description
        t.integer :price
        t.integer :category_id
      end

      create_table :products_translations, :force => true do |t|
        t.string  :name
        t.text    :description
        t.integer :product_id
        t.string  :locale
      end

      create_table :categories, :force => true do |t|
        t.string  :name
        t.string  :default_locale
      end

      create_table :categories_translations, :force => true do |t|
        t.string  :name 
        t.integer :category_id
        t.string  :locale
      end

      create_table :posts, :force => true do |t|
        t.string  :title
        t.string  :body
        t.integer :views
      end

      create_table :posts_translations, :force => true do |t|
        t.string  :title
        t.string  :body
        t.integer :post_id
      end
      ::ARSchema.loading = false
    end
  end
end
