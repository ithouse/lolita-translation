class String
  attr_accessor :origin_model, :origin_name
  def set_origins obj, name
    self.origin_model = obj
    self.origin_name = name
    self
  end
  # forces given locale
  # I18n.locale = :lv
  # a = Article.find 18
  # a.title
  # => "LV title"
  # a.title.in(:en)
  # => "EN title"
  def in locale
    return self unless self.origin_model
    translation = self.origin_model.in(locale) and translation.send(self.origin_name)
  end
end