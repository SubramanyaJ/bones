import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../core/http_service.dart';
import '../core/parser_service.dart';
import '../core/render_service.dart';
import '../models/page_state.dart';

class RenderPage extends StatefulWidget {
  final String initialUrl;
  final String fontFamily;
  final double fontSize;
  final String uiFontFamily;
  final double uiFontSize;

  const RenderPage({
    super.key,
    required this.initialUrl,
    required this.fontFamily,
    required this.fontSize,
    required this.uiFontFamily,
    required this.uiFontSize,
  });

  @override
  State<RenderPage> createState() => _RenderPageState();
}

class _RenderPageState extends State<RenderPage> {
  final BrowserHistory _history = BrowserHistory();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String? _error;
  List<Widget> _content = [];
  String _currentUrl = '';
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _loadUrl(widget.initialUrl);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUrl(String url) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      HttpResponse response = await HttpService.fetchUrl(url);

      if (!response.isSuccess) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      String cleanHtml = ParserService.stripScriptsAndStyles(response.body);
      dom.Document document = ParserService.parseHtml(cleanHtml);

      String title = ParserService.extractTitle(document);
      List<dom.Element> elements = ParserService.extractMainContent(document);

      List<Widget> widgets = RenderService.renderElements(
        elements,
        _onLinkTap,
        response.url,
        context,
        fontFamily: widget.fontFamily,
        fontSize: widget.fontSize,
      );

      setState(() {
        _currentUrl = response.url;
        _pageTitle = title;
        _content = widgets;
        _isLoading = false;
      });

      PageState pageState = PageState(
        url: response.url,
        title: title,
        content: response.body,
      );
      _history.push(pageState);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onLinkTap(String url) {
    _loadUrl(url);
  }

  void _goBack() {
    PageState? page = _history.goBack();
    if (page != null) {
      _loadUrl(page.url);
    }
  }

  void _goForward() {
    PageState? page = _history.goForward();
    if (page != null) {
      _loadUrl(page.url);
    }
  }

  void _refresh() {
    if (_currentUrl.isNotEmpty) {
      _loadUrl(_currentUrl);
    }
  }

  void _showUrlDialog() {
    TextEditingController controller = TextEditingController(text: _currentUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigate to URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                _loadUrl(url);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _pageTitle.isNotEmpty ? _pageTitle : 'Loading...',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontFamily: widget.uiFontFamily,
            fontSize: widget.uiFontSize,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Back",
            color: Colors.white,
            onPressed: _history.canGoBack ? _goBack : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: "Forward",
            color: Colors.white,
            onPressed: _history.canGoForward ? _goForward : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reload",
            color: Colors.white,
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: "Go to URL",
            color: Colors.white,
            onPressed: _showUrlDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return const Center(
        child: Text('No content to display'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _content.length,
      itemBuilder: (context, index) => _content[index],
    );
  }
}
