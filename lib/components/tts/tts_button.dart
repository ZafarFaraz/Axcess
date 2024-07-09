import 'package:flutter/material.dart';

class TTSButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const TTSButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required Null Function() onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = getTextColorForBackground(backgroundColor);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 36.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ColorPair {
  final Color backgroundColor;
  final Color textColor;

  ColorPair(this.backgroundColor, this.textColor);
}

final List<ColorPair> wcagColorPairs = [
  ColorPair(Colors.white, Colors.black),
  ColorPair(Colors.black, Colors.white),
  ColorPair(Color(0xFFF1F1F1), Color(0xFF1A1A1A)),
  ColorPair(Color(0xFFE6FFE6), Color(0xFF004225)),
  ColorPair(Color(0xFFFAE6FF), Color(0xFF3A0045)),
  ColorPair(Color(0xFFFFE6E6), Color(0xFF5B0000)),
  ColorPair(
      Color(0xFF001F3F), Color(0xFF7FDBFF)), // Navy background, light blue text
  ColorPair(Color(0xFF3D9970),
      Color(0xFFDDDDDD)), // Olive background, light gray text
  ColorPair(
      Color(0xFF85144B), Color(0xFFF012BE)), // Maroon background, pink text
  ColorPair(
      Color(0xFFFFDC00), Color(0xFF111111)), // Yellow background, black text
  ColorPair(Color(0xFF39CCCC), Color(0xFF001F3F)), // Teal background, navy text
  ColorPair(Color(0xFF2ECC40), Color(0xFF111111)),
];

Color getTextColorForBackground(Color backgroundColor) {
  for (var pair in wcagColorPairs) {
    if (pair.backgroundColor == backgroundColor) {
      return pair.textColor;
    }
  }
  // Default to black if no match is found
  return Colors.black;
}
