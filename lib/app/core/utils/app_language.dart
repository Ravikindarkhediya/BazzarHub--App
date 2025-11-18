
import '../../../presentation/services/models/Common/multi_lang_text_model.dart';

class AppLanguage {
  // current selected language
  static String _currentLang = "english";
  // values: english, hindi, gujarati

  /// Set selected language
  static void setLanguage(String lang) {
    _currentLang = lang.toLowerCase();
  }

  /// Get selected language
  static String getLanguage() {
    return _currentLang;
  }

  /// Get text from model based on current language
  static String getText(MultiLangTextModel? model) {
    if (model == null) return "";

    switch (_currentLang) {
      case "hindi":
        return model.hindi ?? "";
      case "gujarati":
        return model.gujarati ?? "";
      case "english":
      default:
        return model.english ?? "";
    }
  }
}
