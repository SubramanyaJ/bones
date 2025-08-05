// /lib/widgets/code_block.dart
import 'package:flutter/material.dart';

class CodeBlockWidget extends StatelessWidget {
  final String text;
  final bool inline;

  const CodeBlockWidget({
    super.key,
    required this.text,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: inline ? 14 : 13,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.green[300]
          : Colors.green[800],
    );

    if (inline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(3),
        ),
        child: SelectableText(
          text,
          style: codeStyle,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: SelectableText(
        text,
        style: codeStyle,
      ),
    );
  }
}