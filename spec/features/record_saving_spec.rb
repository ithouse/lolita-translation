require 'spec_helper'

feature "In order to internationalize all content I can enter information in any language and translate to any other language", js: true do

  def click_save_btn
    save_btn = page.find("button[data-type='save&close']")
    save_btn.click
  end

  def create_category options = {}
    default_options = {:name => "name", :default_locale => ::I18n.locale}
    Category.create!(default_options.merge(options))
  end

  scenario "As user I can enter information in same language as system uses and resource will be stored in that language" do
    visit "/lolita/posts/new"
    fill_in "post_title", :with => "lv-title"
    fill_in "post_body", :with => "lv-body"
    click_save_btn
    page.should have_content("lv-title")
    page.should have_content("lv-body")
  end

  scenario "As user I can enter information in language that I am using currently and original resource will be save in that language" do
    visit "/lolita/posts/new?locale=ru"
    fill_in "post_title", :with => "ru-title"
    fill_in "post_body", :with => "ru-body"
    click_save_btn
    visit "/lolita/posts?locale=lv"
    page.should have_content("ru-title")
    page.should have_content("ru-body")
  end

  scenario "As user I can open previously saved resource, in different language than mine, and resource will be shown in resource original language and I will see that" do
    I18n.locale = :ru
    category = create_category(:name => "ru-name")
    visit("/lolita/categories/#{category.id}/edit?locale=lv")
    page.should have_selector(".tab-language-switch li.active", :text => "Ru")
    ru_content = page.find(".language-wrap.active")
    ru_content.should be_visible
  end

  scenario "As user I can open previously saved resource, in different language than mine, and change original information and that information will be save in original resource" do
    I18n.locale = :ru
    category = create_category(:name => "ru-name")
    visit("/lolita/categories/#{category.id}/edit?locale=lv")
    page.fill_in "category_name", :with => "changed-ru-name"
    click_save_btn
    visit("/lolita/categories/#{category.id}/edit?locale=en")
    name_inp = page.find("#category_name")
    name_inp.value.should eq("changed-ru-name")
  end

  scenario "As user I can open previously saved resource, in different language than mine, and change information for my language, and it will be saved as translation", :js => true do
    pending "test gives time, should check why not error but timeout"
    # I18n.locale = :ru
    # category = create_category(:name => "ru-name")
    # visit("/lolita/categories/#{category.id}/edit?locale=lv")
    # page.execute_script(%Q{$(".tab-language-switch li[data-locale='lv']").click()})
    # page.fill_in("Name",:with => "lv-name")
    # click_save_btn
    # page.should have_content("lv-name")
  end
end