

module TranslationHelper
  def t(*params)
    I18n.translate(*params)
  end
  def l(*params)
    I18n.localize(*params)
  end
end
