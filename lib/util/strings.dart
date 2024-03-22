class StringSimplifier {
  static final Map<String, String> specialCharsMapping = {
    'ą': 'a',
    'ż': 'z',
    'ś': 's',
    'ź': 'z',
    'ę': 'e',
    'ć': 'c',
    'ń': 'n',
    'ó': 'o',
    'ł': 'l',
  };

  static String simplify(String s) {
    String s2 = s.toLowerCase();
    specialCharsMapping.forEach((k, v) {
      s2 = s2.replaceAll(k, v);
    });
    return s2;
  }
}

class DeEmojinator {
  final RegExp emojiFilterRegex = RegExp(
      '\\u00a9|\\u00ae|[\\u2000-\\u3300]|\\ud83c[\\ud000-\\udfff]|\\ud83d[\\ud000-\\udfff]|\\ud83e[\\ud000-\\udfff]');

  String simplify(String text) {
    return emojiLess(text).toLowerCase().trim();
  }

  String emojiLess(String text) {
    StringBuffer buffer = StringBuffer();
    int i = 0;
    while (i < text.length) {
      String char = text[i];
      if (isCharEmoji(char)) {
        i++;
      } else if (i + 1 < text.length && is2CharEmoji(char, text[i + 1])) {
        i += 2;
      } else {
        i++;
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  bool isCharEmoji(String char) {
    return char.codeUnitAt(0) == 0x00a9 ||
        char.codeUnitAt(0) == 0x00ae ||
        (char.codeUnitAt(0) >= 0x2000 && char.codeUnitAt(0) <= 0x3300);
  }

  bool is2CharEmoji(String char, String next) {
    return (char.codeUnitAt(0) == 0xd83c &&
            next.codeUnitAt(0) >= 0xd000 &&
            next.codeUnitAt(0) <= 0xdfff) ||
        (char.codeUnitAt(0) == 0xd83d &&
            next.codeUnitAt(0) >= 0xd000 &&
            next.codeUnitAt(0) <= 0xdfff) ||
        (char.codeUnitAt(0) == 0xd83e &&
            next.codeUnitAt(0) >= 0xd000 &&
            next.codeUnitAt(0) <= 0xdfff);
  }
}