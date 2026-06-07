import 'dart:ui';

class LocaleResolver {
  static const _supported = {'en', 'pt'};
  static const _fallback = 'en';

  static String resolve(List<Locale> systemLocales) {
    for (final locale in systemLocales) {
      if (_supported.contains(locale.languageCode)) {
        return locale.languageCode;
      }
    }
    return _fallback;
  }
}
