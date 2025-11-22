enum Suit {
  hearts,
  diamonds,
  clubs,
  spades
}

extension SuitExtensions on Suit {
  String get displayName {
    String n = name;
    return n[0].toUpperCase() + n.substring(1);
  }
}