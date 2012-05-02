module LolitaTranslation
  class Engine < Rails::Engine

  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/error_msg").before do
  tab = self.component_locals[:tab]
  if tab.translatable?
    self.send(:render_component,"lolita/translation",:switch, :tab => tab)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/fields").after do
  tab = self.component_locals[:tab]
  if tab.translatable?
    self.render_component tab.build_translations_nested_form(self.resource)
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tab/fields").around do
  tab = self.component_locals[:tab]
  if tab.translatable?
    content = nil
    resource.in(resource.original_locale) do 
      content = let_content
    end
    self.send(:render_component,"lolita/translation",:language_wrap, {
      :tab => tab, 
      :content => content, 
      :active => true,
      :translation_locale => resource.original_locale
    })
  else
    let_content
  end
end

Lolita::Hooks.component(:"/lolita/configuration/nested_form/fields").around do
  tab = self.component_locals[:nested_form].parent
  if tab.translatable?
    self.send(:render_component,"lolita/translation",:language_wrap, {
      :tab => tab, 
      :content => let_content, 
      :active => false,
      :translation_locale => current_form.object.locale
    })
  else
    let_content
  end
end

Lolita::Hooks.component(:"/lolita/configuration/tabs/display").before do
  self.render_component "lolita/translation", :assets
end