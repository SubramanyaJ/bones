// /lib/widgets/link_text.dart
import 'package:flutter/material.dart';

class LinkTextWidget extends StatelessWidget {
  final String text;
  final String url;
  final Function(String) onTap;

  const LinkTextWidget({
    super.key,
    required this.text,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(url),
      onLongPress: () => _showLinkOptions(context),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showLinkOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open Link'),
            onTap: () {
              Navigator.pop(context);
              onTap(url);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy URL'),
            onTap: () {
              Navigator.pop(context);
              // Copy to clipboard functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied: $url')),
              );
            },
          ),
        ],
      ),
    );
  }
}