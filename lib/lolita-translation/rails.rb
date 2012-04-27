module LolitaTranslation
  class Engine < Rails::Engine

  end
end

# Lolita::Hooks.component(:"/lolita/configuration/tab/error_msg").before do
#   tab = self.component_locals[:tab]
#   if Lolita::Translation.translatable?(tab)
#     self.send(:render_component,"lolita/translation",:switch, :tab => tab)
#   end
# end

# Lolita::Hooks.component(:"/lolita/configuration/tab/fields").after do
#   tab = self.component_locals[:tab]
#   if Lolita::Translation.translatable?(tab)
#     self.render_component Lolita::Translation.create_translations_nested_form(self.resource,tab)
#   end
# end

# Lolita::Hooks.component(:"/lolita/configuration/tab/fields").around do
#   tab = self.component_locals[:tab]
#   if Lolita::Translation.translatable?(tab)
#     self.send(:render_component,"lolita/translation",:language_wrap,:tab => tab, :content => let_content)
#   else
#     let_content
#   end
# end

# Lolita::Hooks.component(:"/lolita/configuration/nested_form/fields").around do
#   tab = self.component_locals[:nested_form].parent
#   if Lolita::Translation.translatable?(tab)
#     self.send(:render_component,"lolita/translation",:language_wrap, :tab => tab, :content => let_content)
#   else
#     let_content
#   end
# end

# Lolita::Hooks.component(:"/lolita/configuration/tabs/display").before do
#   self.render_component "lolita/translation", :assets
# end