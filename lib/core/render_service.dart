import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../widgets/heading.dart';
import '../widgets/list_block.dart';
import '../widgets/table_block.dart';
import '../widgets/code_block.dart';

class RenderService {
  static List<Widget> renderElements(
    List<dom.Element> elements,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    List<Widget> widgets = [];
    for (var element in elements) {
      Widget? widget = _renderElement(element, onLinkTap, baseUrl, context,
          fontFamily: fontFamily, fontSize: fontSize);
      if (widget != null) {
        widgets.add(widget);
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }

  static Widget? _renderElement(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    TextStyle baseStyle = _getUserStyle(fontFamily, fontSize);
    switch (element.localName?.toLowerCase()) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return HeadingWidget(
          text: element.text.trim(),
          level: int.parse(element.localName!.substring(1)),
        );
      case 'p':
        return _renderParagraph(element, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
      case 'blockquote':
        return _renderBlockquote(element, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
      case 'div':
        return _renderDiv(element, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
      case 'a':
        String? href = element.attributes['href'];
        if (href != null) {
          String resolvedUrl = _resolveUrl(href, baseUrl);
          return InkWell(
            onTap: () => onLinkTap(resolvedUrl),
            child: Text(
              element.text.trim(),
              style: baseStyle.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: fontSize,
              ),
            ),
          );
        }
        return Text(element.text.trim(),
            style: baseStyle.copyWith(fontSize: fontSize));
      case 'ul':
      case 'ol':
        return _renderList(element, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
      case 'table':
        return TableBlockWidget(
          rows: element
              .querySelectorAll('tr')
              .map((tr) => tr.querySelectorAll('td, th')
                  .map((cell) => cell.text.trim())
                  .toList())
              .where((row) => row.isNotEmpty)
              .toList(),
        );
      case 'pre':
        return CodeBlockWidget(text: element.text);
      case 'code':
        return CodeBlockWidget(text: element.text, inline: true);
      case 'br':
        return const SizedBox(height: 8);
      case 'hr':
        return const Divider();
      case 'img':
        return _renderImage(element, context);
      default:
        if (element.children.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: renderElements(element.children, onLinkTap, baseUrl,
                context,
                fontFamily: fontFamily, fontSize: fontSize),
          );
        } else if (element.text.trim().isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(element.text.trim(),
                style: baseStyle.copyWith(fontSize: fontSize)),
          );
        }
        return null;
    }
  }

  static Widget? _renderParagraph(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    List<InlineSpan> spans = _renderInlineContent(
        element.nodes, onLinkTap, baseUrl, context,
        fontFamily: fontFamily, fontSize: fontSize);
    if (spans.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SelectableText.rich(
        TextSpan(
          children: spans,
          style: _getUserStyle(fontFamily, fontSize).copyWith(
            height: 1.5,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  static Widget _renderBlockquote(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color border = isDark ? Colors.blueGrey : Colors.grey[400]!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: border,
            width: 4.0,
          ),
        ),
        color: bg,
      ),
      child: SelectableText.rich(
        TextSpan(
          children: _renderInlineContent(
              element.nodes, onLinkTap, baseUrl, context,
              fontFamily: fontFamily, fontSize: fontSize),
          style: _getUserStyle(fontFamily, fontSize).copyWith(
            fontStyle: FontStyle.italic,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  static Widget? _renderDiv(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    String? className = element.attributes['class'];
    bool isIndented = className?.contains('indent') ?? false;
    List<Widget> children = [];
    for (var node in element.nodes) {
      if (node is dom.Text) {
        String text = node.text.trim();
        if (text.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(text, style: _getUserStyle(fontFamily, fontSize)),
            ),
          );
        }
      } else if (node is dom.Element) {
        Widget? widget = _renderElement(node, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
        if (widget != null) children.add(widget);
      }
    }
    if (children.isEmpty && element.nodes.isNotEmpty) {
      List<InlineSpan> spans = _renderInlineContent(
          element.nodes, onLinkTap, baseUrl, context,
          fontFamily: fontFamily, fontSize: fontSize);
      if (spans.isNotEmpty) {
        children.add(
          SelectableText.rich(
            TextSpan(
              children: spans,
              style: _getUserStyle(fontFamily, fontSize).copyWith(
                height: 1.5,
                fontSize: fontSize,
              ),
            ),
          ),
        );
      }
    }
    if (children.isEmpty) return null;
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
    if (isIndented) {
      content = Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 4.0),
        child: content,
      );
    }
    return content;
  }

  static Widget? _renderList(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    List<List<InlineSpan>> items = [];
    for (var li in element.querySelectorAll('li')) {
      List<InlineSpan> itemSpans = _renderInlineContent(
          li.nodes, onLinkTap, baseUrl, context,
          fontFamily: fontFamily, fontSize: fontSize);
      if (itemSpans.isNotEmpty) items.add(itemSpans);
    }
    if (items.isEmpty) return null;
    return ListBlockWidget(
      items: items,
      isOrdered: element.localName == 'ol',
    );
  }

  static Widget _renderImage(dom.Element element, BuildContext context) {
    String? alt = element.attributes['alt'];
    String? src = element.attributes['src'];
    String? title = element.attributes['title'];
    bool hasSrc = src != null && src.isNotEmpty;
    String hash = src != null
        ? sha512.convert(utf8.encode(src)).toString().substring(0, 16)
        : '(no src)';
    Color bg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.grey[100]!;

    return InkWell(
      onTap: hasSrc
          ? () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: Image.network(
                      src!,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.image, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alt != null)
                      Text(
                        alt,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    if (src != null)
                      Text(
                        src,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      'sha512: $hash',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  static List<InlineSpan> _renderInlineContent(
    List<dom.Node> nodes,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    List<InlineSpan> spans = [];
    TextStyle baseStyle = _getUserStyle(fontFamily, fontSize);
    for (var node in nodes) {
      if (node is dom.Text) {
        String text = node.text;
        if (text.trim().isNotEmpty || text.contains('\n')) {
          if (text.contains('\n')) {
            var lines = text.split('\n');
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].trim().isNotEmpty) {
                spans.add(TextSpan(text: lines[i], style: baseStyle));
              }
              if (i < lines.length - 1) {
                spans.add(const TextSpan(text: '\n'));
              }
            }
          } else {
            spans.add(TextSpan(text: text, style: baseStyle));
          }
        }
      } else if (node is dom.Element) {
        InlineSpan? span = _renderInlineElement(
          node, onLinkTap, baseUrl, context,
          fontFamily: fontFamily, fontSize: fontSize);
        if (span != null) {
          spans.add(span);
        }
      }
    }
    return spans;
  }

  static InlineSpan? _renderInlineElement(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
    BuildContext context, {
    required String fontFamily,
    required double fontSize,
  }) {
    TextStyle baseStyle = _getUserStyle(fontFamily, fontSize);
    switch (element.localName?.toLowerCase()) {
      case 'a':
        String? href = element.attributes['href'];
        if (href != null) {
          String resolvedUrl = _resolveUrl(href, baseUrl);
          return WidgetSpan(
            child: GestureDetector(
              onTap: () => onLinkTap(resolvedUrl),
              child: Text(
                element.text.trim(),
                style: baseStyle.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: fontSize,
                ),
              ),
            ),
          );
        }
        return TextSpan(text: element.text.trim(), style: baseStyle.copyWith(fontSize: fontSize));
      case 'strong':
      case 'b':
        List<InlineSpan> children = _renderInlineContent(
            element.nodes, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
        return TextSpan(
          children: children,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: fontSize),
        );
      case 'em':
      case 'i':
        List<InlineSpan> children = _renderInlineContent(
            element.nodes, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
        return TextSpan(
          children: children,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic, fontSize: fontSize),
        );
      case 'u':
        List<InlineSpan> children = _renderInlineContent(
            element.nodes, onLinkTap, baseUrl, context,
            fontFamily: fontFamily, fontSize: fontSize);
        return TextSpan(
          children: children,
          style: baseStyle.copyWith(decoration: TextDecoration.underline, fontSize: fontSize),
        );
      case 'br':
        return const TextSpan(text: '\n');
      case 'img':
        String? alt = element.attributes['alt'];
        return TextSpan(
          text: '[${alt ?? 'Image'}] ',
          style: baseStyle.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: fontSize,
          ),
        );
      default:
        if (element.children.isNotEmpty || element.text.trim().isNotEmpty) {
          List<InlineSpan> children = _renderInlineContent(
              element.nodes, onLinkTap, baseUrl, context,
              fontFamily: fontFamily, fontSize: fontSize);
          if (children.isNotEmpty) {
            return TextSpan(children: children, style: baseStyle.copyWith(fontSize: fontSize));
          }
        }
        return TextSpan(text: element.text.trim(), style: baseStyle.copyWith(fontSize: fontSize));
    }
  }

  static String _resolveUrl(String href, String baseUrl) {
    if (href.startsWith('http://') || href.startsWith('https://')) {
      return href;
    }
    if (href.startsWith('mailto:')) {
      return href;
    }
    Uri baseUri = Uri.parse(baseUrl);
    if (href.startsWith('/')) {
      return '${baseUri.scheme}://${baseUri.host}$href';
    }
    if (href.startsWith('#')) {
      return baseUrl;
    }
    String basePath = baseUri.path;
    if (!basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.lastIndexOf('/') + 1);
    }
    return '${baseUri.scheme}://${baseUri.host}$basePath$href';
  }

  static TextStyle _getUserStyle(String fontFamily, double fontSize) {
    // These family names must exactly match your pubspec.yaml
    switch (fontFamily) {
      case 'TimesNewRoman':
        return TextStyle(fontFamily: 'TimesNewRoman', fontSize: fontSize);
      case 'FiraCode':
        return TextStyle(fontFamily: 'FiraCode', fontSize: fontSize);
      default:
        return TextStyle(fontSize: fontSize);
    }
  }
}