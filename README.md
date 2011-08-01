LolitaHasTranslations
======================

This is a fork of http://github.com/dmitry/has_translations with small changes.

1. The main difference is that the translations table holds only translations, but not the original data from default_locale, so:

    I18n.default_locale = :en
    I18n.locale = :lv
    
    a = Article.create :title => "Title in EN"
    a.title
    # returns blank, because current locale is LV and there is no translation in it
    => ""
    I18n.locale = :en
    a.title
    => "Title in EN"
    a.translations.create :title => "Title in LV", :locale => 'lv'
    I18n.locale = :lv
    a.title
    => "Title in LV"

2. When a "find" is executed and current language is not the same as default language then :translations are added to :includes
   to pre fetch all translations.

3. The "ModelNameTranslation" class is created for you automaticly with all validations for ranslated fields. Of course you can create it manualy for custom vlidations and other.

4. You dont have to create migration for the translation table, just add a line for every translated model in `db/seed.rb`

    TextPage.sync_translation_table!
    Blog::Article.sync_translation_table!

   And run `rake db:seed` and it will do it for you. It also updates the table if you add news columns in the `translations :name, :title .....` method.
