require 'spec_helper'

feature "In order to translate resource As system user I want to switch from original resource to translations" do

  scenario "As user in resource create form I see language switch and current language is active and I can switch to other languages" do
    visit "/lolita/posts/new"
    language_selector_text = page.find(".tab-language-switch").text
    ::I18n.available_locales.each do |locale|
      language_selector_text.should match(/#{locale.to_s.capitalize}/)
    end
  end

end