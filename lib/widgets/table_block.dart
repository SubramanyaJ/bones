// /lib/widgets/table_block.dart
import 'package:flutter/material.dart';

class TableBlockWidget extends StatelessWidget {
  final List<List<String>> rows;

  const TableBlockWidget({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: rows.map((row) {
            return TableRow(
              children: row.map((cell) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    cell,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}