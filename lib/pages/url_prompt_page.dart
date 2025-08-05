// /lib/pages/url_prompt_page.dart
import 'package:flutter/material.dart';
import 'render_page.dart';

class URLPromptPage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const URLPromptPage({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<URLPromptPage> createState() => _URLPromptPageState();
}

class _URLPromptPageState extends State<URLPromptPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToUrl() {
    String url = _controller.text.trim();
    if (url.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RenderPage(
            initialUrl: url,
            onThemeToggle: widget.onThemeToggle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bones Browser'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.language,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter a URL to browse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _navigateToUrl(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToUrl,
                child: const Text('Go'),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'A minimalist text-only browser\nNo JavaScript • No CSS • Just content',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}