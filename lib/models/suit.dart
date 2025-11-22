import 'package:flutter/material.dart';

enum Suit {
  hearts(IconData(0x2665)),
  diamonds(IconData(0x2666)),
  clubs(IconData(0x2663)),
  spades(IconData(0x2660));

  final IconData icon;

  const Suit(this.icon);
}

extension SuitExtensions on Suit {
  String get displayName {
    String n = name;
    return n[0].toUpperCase() + n.substring(1);
  }
}