// /lib/widgets/list_block.dart
import 'package:flutter/material.dart';

class ListBlockWidget extends StatelessWidget {
  final List<List<InlineSpan>> items;
  final bool isOrdered;

  const ListBlockWidget({
    super.key,
    required this.items,
    this.isOrdered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          List<InlineSpan> item = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    isOrdered ? '${index + 1}.' : '•',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(
                      children: item,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}