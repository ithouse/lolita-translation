require 'spec_helper'

if USE_RAILS
  describe "In order to translate record As system user I want to switch from original record to translations", :js => true do 

    it "As user in record create form I see language switch and current language is active and I can switch to other languages" do 
      Post.create!(:title => "AAAAAAAAAAAAAAAA")
      Post.create!(:title => "BBBBBBBBBBBBBBBB")
      visit "/lolita/posts"
      sleep 5
      Post.create!(:title => "AAAAAAAAAAAAAAAA")
      Post.create!(:title => "BBBBBBBBBBBBBBBB")
      visit "/lolita/posts"
      sleep 5
    end

  end
end