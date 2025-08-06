import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'render_page.dart';

class URLPromptPage extends StatefulWidget {
  final String fontFamily;
  final double fontSize;
  final void Function(String) onFontChange;
  final void Function(double) onFontSizeChange;
  final String uiFontFamily;
  final double uiFontSize;

  const URLPromptPage({
    super.key,
    required this.fontFamily,
    required this.fontSize,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.uiFontFamily,
    required this.uiFontSize,
  });

  @override
  State<URLPromptPage> createState() => _URLPromptPageState();
}

class _URLPromptPageState extends State<URLPromptPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> recentSites = [];
  List<String> bookmarks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _loadPrefs();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToUrl([String? overrideUrl]) async {
    String url = overrideUrl ?? _controller.text.trim();
    if (url.isNotEmpty) {
      await _addToRecent(url);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RenderPage(
            initialUrl: url,
            fontFamily: widget.fontFamily,
            fontSize: widget.fontSize,
            uiFontFamily: widget.uiFontFamily,
            uiFontSize: widget.uiFontSize,
          ),
        ),
      );
    }
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSites = prefs.getStringList('recentSites') ?? [];
      bookmarks = prefs.getStringList('bookmarks') ?? [];
    });
  }

  Future<void> _addToRecent(String url) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSites.remove(url);
      recentSites.insert(0, url);
      if (recentSites.length > 10) recentSites = recentSites.sublist(0, 10);
    });
    await prefs.setStringList('recentSites', recentSites);
  }

  Future<void> _addToBookmarks(String url) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!bookmarks.contains(url)) {
        bookmarks.insert(0, url);
      }
    });
    await prefs.setStringList('bookmarks', bookmarks);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmarked: $url')),
    );
  }

  Widget _fontControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: widget.fontFamily,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'FiraCode', child: Text("Fira Code")),
                DropdownMenuItem(value: 'TimesNewRoman', child: Text("Times New Roman")),
                DropdownMenuItem(value: 'Default', child: Text("System Default")),
              ],
              onChanged: (value) {
                if (value != null) widget.onFontChange(value);
              },
              underline: Container(
                height: 1,
                color: Colors.grey,
              ),
              style: TextStyle(
                fontFamily: widget.uiFontFamily,
                fontSize: widget.uiFontSize,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 20,
                    divisions: 10,
                    activeColor: const Color(0xFF008080),
                    value: widget.fontSize.clamp(10, 20),
                    label: widget.fontSize.toInt().toString(),
                    onChanged: (value) => widget.onFontSizeChange(value),
                  ),
                ),
                Text(
                  widget.fontSize.toInt().toString(),
                  style: TextStyle(
                    fontFamily: widget.uiFontFamily,
                    fontSize: widget.uiFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _siteList(String heading, List<String> list, bool allowBookmark, Color iconColor) {
    if (list.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8),
          child: Text(
            heading,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: widget.uiFontFamily,
            ),
          ),
        ),
        ...list.map((url) => ListTile(
          title: Text(
            url,
            style: TextStyle(
              fontSize: 14,
              fontFamily: widget.uiFontFamily,
            ),
          ),
          trailing: allowBookmark
              ? IconButton(
                  icon: Icon(Icons.bookmark_add, color: iconColor),
                  tooltip: 'Bookmark',
                  onPressed: () => _addToBookmarks(url),
                )
              : null,
          onTap: () => _navigateToUrl(url),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // Slimmer bar!
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'bones',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF008080),
              letterSpacing: 1,
              fontFamily: widget.uiFontFamily,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          _fontControls(),
          Center(
            child: Text(
              'Enter a URL to browse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: widget.uiFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
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
                  style: TextStyle(
                    fontFamily: widget.uiFontFamily,
                    fontSize: widget.uiFontSize,
                  ),
                  cursorColor: const Color(0xFF008080),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _navigateToUrl,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  backgroundColor: const Color(0xFF008080),
                  textStyle: TextStyle(
                    fontFamily: widget.uiFontFamily,
                    fontSize: widget.uiFontSize,
                  ),
                ),
                child: const Text('Go'),
              ),
            ],
          ),
          _siteList('Recent Sites', recentSites, true, const Color(0xFF008080)),
          _siteList('Bookmarks', bookmarks, false, Colors.redAccent),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'If you have a problem, open an issue on GitHub.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: widget.uiFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}