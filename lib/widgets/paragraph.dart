// /lib/widgets/paragraph.dart
import 'package:flutter/material.dart';

class ParagraphWidget extends StatelessWidget {
  final List<InlineSpan> children;

  const ParagraphWidget({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SelectableText.rich(
        TextSpan(
          children: children,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
      ),
    );
  }
}