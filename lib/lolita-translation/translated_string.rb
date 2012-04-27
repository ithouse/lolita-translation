class TranslatedString < String 
  def initialize(str, translation_record, attribute_name)
    @translation_record = translation_record
    @attribute_name     = attribute_name
    super(str)
  end

  def in(locale)
    @translation_record.translated_attribute(@attribute_name, :locale => locale)
  end
end