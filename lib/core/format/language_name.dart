const _names = {
  'en': 'English',
  'ja': 'Japanese',
  'ko': 'Korean',
  'zh': 'Chinese',
  'cn': 'Cantonese',
  'fr': 'French',
  'es': 'Spanish',
  'de': 'German',
  'it': 'Italian',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'hi': 'Hindi',
  'id': 'Indonesian',
  'th': 'Thai',
  'tr': 'Turkish',
};

/// "en" becomes "English". Codes we don't have a name for are shown upper-cased
/// ("SV") so the information isn't lost.
String? languageName(String? code) {
  final value = code?.trim().toLowerCase();
  if (value == null || value.isEmpty) return null;
  return _names[value] ?? value.toUpperCase();
}
