# LolitaTranslations


### Install

    gem "lolita-translation"

### Usage

1. Add `include Lolita::Translation` in your model.
2. Call `translate :title, :body` in your model and pass column names to translate.
3. Add `Article.sync_translation_table!` to your `db/seeds.rb` and run it.

#### What it does?
In Lolita, each tab, that contains at least on field, that needs to be translated, is changed to translatable tab.

### Examples

Translations table holds only translations, but not the original data from default_locale, so:

    I18n.default_locale = :en
    I18n.locale = :lv

    a = Article.create :title => "Title in EN"
    a.title # returns blank, because current locale is LV and there is no translation in it
    #=> ""
    I18n.locale = :en
    a.title
    #=> "Title in EN"
    a.translations.create :title => "Title in LV", :locale => 'lv'
    I18n.locale = :lv
    a.title
    #=> "Title in LV"

    a.in(:lv).title #returns record's title attribute in locale that's passed
    #=> "Title in LV"

When a "find" is executed and current language is not the same as default language then `:translations` are added to `:includes` to pre fetch all translations.

The `ModelNameTranslation` class is created for you automaticly with all validations for ranslated fields. Of course you can create it manualy for custom vlidations and other.


### Credits

Inspired by http://github.com/dmitry/has_translations

### License

Copyright © 2011 ITHouse. See LICENSE.txt for further details.
