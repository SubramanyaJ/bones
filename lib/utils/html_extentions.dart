// /lib/utils/html_extensions.dart
extension StringExtensions on String {
  String normalizeWhitespace() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  
  bool get isValidUrl {
    try {
      Uri.parse(this);
      return startsWith('http://') || startsWith('https://');
    } catch (e) {
      return false;
    }
  }
}

extension ElementExtensions on dynamic {
  String get textContent {
    if (this == null) return '';
    return toString().trim();
  }
}