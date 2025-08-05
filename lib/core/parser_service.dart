// /lib/core/parser_service.dart
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class ParserService {
  static dom.Document parseHtml(String htmlContent) {
    return html_parser.parse(htmlContent);
  }

  static List<dom.Element> extractMainContent(dom.Document document) {
    // Try to find main content areas first
    var mainContent = document.querySelector('main') ??
                     document.querySelector('article') ??
                     document.querySelector('#content') ??
                     document.querySelector('.content') ??
                     document.querySelector('body');

    if (mainContent != null) {
      return mainContent.children;
    }

    return document.body?.children ?? [];
  }

  static String extractTitle(dom.Document document) {
    var titleElement = document.querySelector('title');
    if (titleElement != null && titleElement.text.trim().isNotEmpty) {
      return titleElement.text.trim();
    }

    var h1 = document.querySelector('h1');
    if (h1 != null && h1.text.trim().isNotEmpty) {
      return h1.text.trim();
    }

    return 'Untitled Page';
  }

  static List<String> extractLinks(dom.Document document) {
    return document
        .querySelectorAll('a[href]')
        .map((element) => element.attributes['href'] ?? '')
        .where((href) => href.isNotEmpty)
        .toList();
  }

  static String stripScriptsAndStyles(String htmlContent) {
    var document = html_parser.parse(htmlContent);
    
    // Remove script tags
    document.querySelectorAll('script').forEach((element) {
      element.remove();
    });

    // Remove style tags
    document.querySelectorAll('style').forEach((element) {
      element.remove();
    });

    // Remove noscript tags
    document.querySelectorAll('noscript').forEach((element) {
      element.remove();
    });

    return document.outerHtml;
  }
}