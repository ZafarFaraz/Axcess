import 'package:flutter/material.dart';

import '../colors.dart';

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
