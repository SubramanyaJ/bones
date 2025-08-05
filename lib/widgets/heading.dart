// /lib/widgets/heading.dart
import 'package:flutter/material.dart';

class HeadingWidget extends StatelessWidget {
  final String text;
  final int level;

  const HeadingWidget({
    super.key,
    required this.text,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    FontWeight fontWeight = FontWeight.bold;

    switch (level) {
      case 1:
        fontSize = 28;
        break;
      case 2:
        fontSize = 24;
        break;
      case 3:
        fontSize = 20;
        break;
      case 4:
        fontSize = 18;
        break;
      case 5:
        fontSize = 16;
        break;
      case 6:
        fontSize = 14;
        break;
      default:
        fontSize = 16;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.2,
        ),
      ),
    );
  }
}