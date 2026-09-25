enum AppLanguage {
  english('en', 'English', 'English', 'Hi!', 'What are we studying today?'),
  hindi('hi', 'हिन्दी', 'Hindi', 'नमस्ते!', 'आज हम क्या पढ़ें?'),
  telugu('te', 'తెలుగు', 'Telugu', 'నమస్తే!', 'ఈరోజు ఏం చదువుదాం?'),
  tamil('ta', 'தமிழ்', 'Tamil', 'வணக்கம்!', 'இன்று என்ன படிப்போம்?'),
  bengali('bn', 'বাংলা', 'Bengali', 'নমস্কার!', 'আজ আমরা কী পড়ব?');

  const AppLanguage(
    this.code,
    this.nativeName,
    this.englishName,
    this.greeting,
    this.sample,
  );

  final String code;
  final String nativeName;
  final String englishName;
  final String greeting;
  final String sample;

  static const comingSoon = [
    'मराठी',
    'ಕನ್ನಡ',
    'മലയാളം',
    'ગુજરાતી',
    'ਪੰਜਾਬੀ',
    'ଓଡ଼ିଆ',
    'اردو',
  ];

  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}
