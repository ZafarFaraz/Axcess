import 'package:flutter/material.dart';

class ColorPair {
  final Color backgroundColor;
  final Color textColor;

  ColorPair(this.backgroundColor, this.textColor);
}

final List<ColorPair> wcagColorPairs = [
  ColorPair(Colors.white, Colors.black),
  ColorPair(Colors.black, Colors.white),
  ColorPair(const Color(0xFFF1F1F1), const Color(0xFF1A1A1A)),
  ColorPair(const Color(0xFFE6FFE6), const Color(0xFF004225)),
  ColorPair(const Color(0xFFFAE6FF), const Color(0xFF3A0045)),
  ColorPair(const Color(0xFFFFE6E6), const Color(0xFF5B0000)),
  ColorPair(
      const Color(0xFF001F3F), const Color(0xFF7FDBFF)), // Navy background, light blue text
  ColorPair(const Color(0xFF3D9970),
      const Color(0xFFDDDDDD)), // Olive background, light gray text
  ColorPair(
      const Color(0xFF85144B), const Color(0xFFF012BE)), // Maroon background, pink text
  ColorPair(
      const Color(0xFFFFDC00), const Color(0xFF111111)), // Yellow background, black text
  ColorPair(const Color(0xFF39CCCC), const Color(0xFF001F3F)), // Teal background, navy text
  ColorPair(const Color(0xFF2ECC40), const Color(0xFF111111)),
];

Color getTextColorForBackground(Color backgroundColor) {
  // Example function to determine text color based on background color
  return (backgroundColor.computeLuminance() > 0.5)
      ? Colors.black
      : Colors.white;
}
