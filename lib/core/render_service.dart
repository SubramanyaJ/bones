// /lib/core/render_service.dart
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../widgets/heading.dart';
import '../widgets/paragraph.dart';
import '../widgets/link_text.dart';
import '../widgets/list_block.dart';
import '../widgets/table_block.dart';
import '../widgets/code_block.dart';

class RenderService {
  static List<Widget> renderElements(
    List<dom.Element> elements,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<Widget> widgets = [];

    for (var element in elements) {
      Widget? widget = _renderElement(element, onLinkTap, baseUrl);
      if (widget != null) {
        widgets.add(widget);
        widgets.add(const SizedBox(height: 8)); // Spacing between elements
      }
    }

    return widgets;
  }

  static Widget? _renderElement(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    switch (element.localName?.toLowerCase()) {
      // Document Structure
      case 'html':
      case 'head':
      case 'body':
      case 'title':
      case 'meta':
      case 'link':
      case 'style':
      case 'script':
        return null; // These are handled by parser or ignored

      // Headings
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

      // Text Content
      case 'p':
        return _renderParagraph(element, onLinkTap, baseUrl);

      case 'blockquote':
        return _renderBlockquote(element, onLinkTap, baseUrl);

      case 'pre':
        return CodeBlockWidget(text: element.text);

      case 'code':
        return CodeBlockWidget(text: element.text, inline: true);

      case 'address':
        return _renderAddress(element, onLinkTap, baseUrl);

      // Lists
      case 'ul':
      case 'ol':
        return _renderList(element, onLinkTap, baseUrl);

      case 'dl':
        return _renderDescriptionList(element, onLinkTap, baseUrl);

      // Links
      case 'a':
        String? href = element.attributes['href'];
        if (href != null) {
          String resolvedUrl = _resolveUrl(href, baseUrl);
          return LinkTextWidget(
            text: element.text.trim(),
            url: resolvedUrl,
            onTap: onLinkTap,
          );
        }
        return Text(element.text.trim());

      // Tables
      case 'table':
        return _renderTable(element);

      case 'caption':
        return _renderCaption(element, onLinkTap, baseUrl);

      // Media
      case 'img':
        return _renderImage(element);

      case 'audio':
        return _renderAudio(element);

      case 'video':
        return _renderVideo(element);

      case 'canvas':
        return _renderCanvas(element);

      // Forms (display only, no functionality)
      case 'form':
      case 'fieldset':
        return _renderFormContainer(element, onLinkTap, baseUrl);

      case 'input':
        return _renderInput(element);

      case 'textarea':
        return _renderTextarea(element);

      case 'select':
        return _renderSelect(element);

      case 'button':
        return _renderButton(element);

      case 'label':
        return _renderLabel(element, onLinkTap, baseUrl);

      case 'legend':
        return _renderLegend(element, onLinkTap, baseUrl);

      // Sectioning
      case 'header':
      case 'nav':
      case 'main':
      case 'section':
      case 'article':
      case 'aside':
      case 'footer':
        return _renderSection(element, onLinkTap, baseUrl);

      case 'div':
        return _renderDiv(element, onLinkTap, baseUrl);

      case 'span':
        return _renderSpan(element, onLinkTap, baseUrl);

      // Separators
      case 'hr':
        return const Divider();

      case 'br':
        return const SizedBox(height: 8);

      // Details/Summary
      case 'details':
        return _renderDetails(element, onLinkTap, baseUrl);

      case 'summary':
        return _renderSummary(element, onLinkTap, baseUrl);

      // Data/Time
      case 'time':
        return _renderTime(element, onLinkTap, baseUrl);

      case 'data':
        return _renderData(element, onLinkTap, baseUrl);

      // Progress/Meter
      case 'progress':
        return _renderProgress(element);

      case 'meter':
        return _renderMeter(element);

      // Ruby annotations (for East Asian typography)
      case 'ruby':
      case 'rt':
      case 'rp':
        return _renderRuby(element, onLinkTap, baseUrl);

      // Figures
      case 'figure':
        return _renderFigure(element, onLinkTap, baseUrl);

      case 'figcaption':
        return _renderFigcaption(element, onLinkTap, baseUrl);

      // Embedded content frames
      case 'iframe':
      case 'embed':
      case 'object':
        return _renderEmbeddedContent(element);

      default:
        // Handle any unrecognized element by rendering its children
        if (element.children.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: renderElements(element.children, onLinkTap, baseUrl),
          );
        } else if (element.text.trim().isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              element.text.trim(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }
        return null;
    }
  }

  // Existing methods remain the same...
  static Widget? _renderParagraph(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<InlineSpan> spans =
        _renderInlineContent(element.nodes, onLinkTap, baseUrl);

    if (spans.isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SelectableText.rich(
        TextSpan(
          children: spans,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget? _renderDiv(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    String? className = element.attributes['class'];
    bool isIndented = className?.contains('indent') ?? false;

    List<Widget> children = [];

    // Handle mixed content (text nodes and elements)
    for (var node in element.nodes) {
      if (node is dom.Text) {
        String text = node.text.trim();
        if (text.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }
      } else if (node is dom.Element) {
        Widget? widget = _renderElement(node, onLinkTap, baseUrl);
        if (widget != null) {
          children.add(widget);
        }
      }
    }

    // If no children were rendered, try to render as inline content
    if (children.isEmpty && element.nodes.isNotEmpty) {
      List<InlineSpan> spans =
          _renderInlineContent(element.nodes, onLinkTap, baseUrl);
      if (spans.isNotEmpty) {
        children.add(
          SelectableText.rich(
            TextSpan(
              children: spans,
              style: const TextStyle(fontSize: 16, height: 1.5),
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
  ) {
    List<List<InlineSpan>> items = [];

    for (var li in element.querySelectorAll('li')) {
      List<InlineSpan> itemSpans =
          _renderInlineContent(li.nodes, onLinkTap, baseUrl);
      if (itemSpans.isNotEmpty) {
        items.add(itemSpans);
      }
    }

    if (items.isEmpty) return null;

    return ListBlockWidget(
      items: items,
      isOrdered: element.localName == 'ol',
    );
  }

  // New methods for handling additional HTML elements
  static Widget _renderBlockquote(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<InlineSpan> spans =
        _renderInlineContent(element.nodes, onLinkTap, baseUrl);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[400]!,
            width: 4.0,
          ),
        ),
        color: Colors.grey[100],
      ),
      child: SelectableText.rich(
        TextSpan(
          children: spans,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget _renderAddress(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectableText.rich(
        TextSpan(
          children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  static Widget _renderDescriptionList(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<Widget> items = [];

    for (var child in element.children) {
      if (child.localName == 'dt') {
        // Definition term
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SelectableText.rich(
              TextSpan(
                children: _renderInlineContent(child.nodes, onLinkTap, baseUrl),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else if (child.localName == 'dd') {
        // Definition description
        items.add(
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 4.0),
            child: SelectableText.rich(
              TextSpan(
                children: _renderInlineContent(child.nodes, onLinkTap, baseUrl),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  static Widget _renderTable(dom.Element element) {
    List<List<String>> rows = [];

    // Handle thead, tbody, tfoot
    var tableRows = element.querySelectorAll('tr');

    for (var tr in tableRows) {
      List<String> row = [];
      var cells = tr.querySelectorAll('td, th');
      for (var cell in cells) {
        row.add(cell.text.trim());
      }
      if (row.isNotEmpty) {
        rows.add(row);
      }
    }

    if (rows.isEmpty) return const Text('Empty table');

    return TableBlockWidget(rows: rows);
  }

  static Widget _renderCaption(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SelectableText.rich(
          TextSpan(
            children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _renderImage(dom.Element element) {
    String? alt = element.attributes['alt'];
    String? src = element.attributes['src'];
    String? title = element.attributes['title'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alt ?? 'Image',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
          if (src != null) ...[
            const SizedBox(height: 4),
            Text(
              'Source: $src',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _renderAudio(dom.Element element) {
    String? src = element.attributes['src'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (src != null)
                  Text(
                    src,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _renderVideo(dom.Element element) {
    String? src = element.attributes['src'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.videocam, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (src != null)
                  Text(
                    src,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _renderCanvas(dom.Element element) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.brush, size: 20, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Canvas Element',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static Widget _renderFormContainer(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element.localName!.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...renderElements(element.children, onLinkTap, baseUrl),
        ],
      ),
    );
  }

  static Widget _renderInput(dom.Element element) {
    String? type = element.attributes['type'] ?? 'text';
    String? value = element.attributes['value'];
    String? placeholder = element.attributes['placeholder'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Icon(
            _getInputIcon(type),
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? placeholder ?? 'Input ($type)',
              style: TextStyle(
                fontSize: 14,
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _renderTextarea(dom.Element element) {
    String content = element.text.trim();
    String? placeholder = element.attributes['placeholder'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        content.isNotEmpty ? content : (placeholder ?? 'Textarea'),
        style: TextStyle(
          fontSize: 14,
          color: content.isNotEmpty ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  static Widget _renderSelect(dom.Element element) {
    var options = element.querySelectorAll('option');
    String selectedText = 'Select';

    for (var option in options) {
      if (option.attributes.containsKey('selected')) {
        selectedText = option.text.trim();
        break;
      }
    }

    if (selectedText == 'Select' && options.isNotEmpty) {
      selectedText = options.first.text.trim();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            selectedText,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget _renderButton(dom.Element element) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.grey[100],
      ),
      child: Text(
        element.text.trim().isNotEmpty ? element.text.trim() : 'Button',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  static Widget _renderLabel(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: SelectableText.rich(
        TextSpan(
          children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget _renderLegend(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText.rich(
        TextSpan(
          children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _renderSection(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (element.localName != 'div') // Don't show tag for div
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '${element.localName!.toUpperCase()}:',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...renderElements(element.children, onLinkTap, baseUrl),
      ],
    );
  }

  static Widget? _renderSpan(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<InlineSpan> spans =
        _renderInlineContent(element.nodes, onLinkTap, baseUrl);
    if (spans.isEmpty) return null;

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  static Widget _renderDetails(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    var summary = element.querySelector('summary');
    String summaryText = summary?.text.trim() ?? 'Details';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(summaryText),
        children: renderElements(
          element.children.where((e) => e.localName != 'summary').toList(),
          onLinkTap,
          baseUrl,
        ),
      ),
    );
  }

  static Widget _renderSummary(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    // Summary is handled by details element
    return const SizedBox.shrink();
  }

  static Widget _renderTime(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    String? datetime = element.attributes['datetime'];
    String displayText = element.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  static Widget _renderData(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    String? value = element.attributes['value'];
    String displayText = element.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Text(
        displayText,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  static Widget _renderProgress(dom.Element element) {
    String? value = element.attributes['value'];
    String? max = element.attributes['max'];

    double progress = 0.0;
    if (value != null && max != null) {
      double val = double.tryParse(value) ?? 0.0;
      double maxVal = double.tryParse(max) ?? 100.0;
      progress = val / maxVal;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progress),
          if (value != null && max != null)
            Text(
              '$value / $max',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  static Widget _renderMeter(dom.Element element) {
    String? value = element.attributes['value'];
    String? min = element.attributes['min'];
    String? max = element.attributes['max'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Meter: ${value ?? 'N/A'}${min != null && max != null ? ' ($min-$max)' : ''}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget _renderRuby(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    // Simplified ruby rendering - just show the text
    return SelectableText.rich(
      TextSpan(
        children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  static Widget _renderFigure(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderElements(element.children, onLinkTap, baseUrl),
      ),
    );
  }

  static Widget _renderFigcaption(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SelectableText.rich(
        TextSpan(
          children: _renderInlineContent(element.nodes, onLinkTap, baseUrl),
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  static Widget _renderEmbeddedContent(dom.Element element) {
    String? src = element.attributes['src'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.web, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${element.localName!.toUpperCase()} Content',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (src != null) ...[
            const SizedBox(height: 4),
            Text(
              'Source: $src',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _getInputIcon(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'password':
        return Icons.lock;
      case 'search':
        return Icons.search;
      case 'tel':
        return Icons.phone;
      case 'url':
        return Icons.link;
      case 'number':
        return Icons.numbers;
      case 'date':
        return Icons.calendar_today;
      case 'time':
        return Icons.access_time;
      case 'file':
        return Icons.attach_file;
      case 'checkbox':
        return Icons.check_box_outline_blank;
      case 'radio':
        return Icons.radio_button_unchecked;
      case 'submit':
        return Icons.send;
      case 'button':
        return Icons.smart_button;
      default:
        return Icons.text_fields;
    }
  }

  // Existing inline rendering methods remain the same...
  static List<InlineSpan> _renderInlineContent(
    List<dom.Node> nodes,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    List<InlineSpan> spans = [];

    for (var node in nodes) {
      if (node is dom.Text) {
        String text = node.text;
        if (text.trim().isNotEmpty || text.contains('\n')) {
          // Handle line breaks
          if (text.contains('\n')) {
            var lines = text.split('\n');
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].trim().isNotEmpty) {
                spans.add(TextSpan(text: lines[i]));
              }
              if (i < lines.length - 1) {
                spans.add(const TextSpan(text: '\n'));
              }
            }
          } else {
            spans.add(TextSpan(text: text));
          }
        }
      } else if (node is dom.Element) {
        InlineSpan? span = _renderInlineElement(node, onLinkTap, baseUrl);
        if (span != null) {
          spans.add(span);
        }
      }
    }

    return spans;
  }

// /lib/core/render_service.dart - Alternative approach with better nested handling
  static InlineSpan? _renderInlineElement(
    dom.Element element,
    Function(String) onLinkTap,
    String baseUrl,
  ) {
    // First, check if this element contains only text
    bool hasOnlyText = element.nodes.every((node) => node is dom.Text);

    // Get base style for this element
    TextStyle? elementStyle = _getElementStyle(element);

    if (hasOnlyText && elementStyle != null) {
      // Simple case: element with only text content
      String text = element.text.trim();

      // Special handling for links
      if (element.localName?.toLowerCase() == 'a') {
        String? href = element.attributes['href'];
        if (href != null) {
          String resolvedUrl = _resolveUrl(href, baseUrl);
          return WidgetSpan(
            child: GestureDetector(
              onTap: () => onLinkTap(resolvedUrl),
              child: Text(
                text,
                style: elementStyle.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.combine([
                    TextDecoration.underline,
                    if (elementStyle.decoration != null)
                      elementStyle.decoration!,
                  ]),
                ),
              ),
            ),
          );
        }
      }

      return TextSpan(
        text: text,
        style: elementStyle,
      );
    } else {
      // Complex case: element with mixed content or nested elements
      List<InlineSpan> children =
          _renderInlineContent(element.nodes, onLinkTap, baseUrl);

      // Special handling for links with nested content
      if (element.localName?.toLowerCase() == 'a') {
        String? href = element.attributes['href'];
        if (href != null) {
          String resolvedUrl = _resolveUrl(href, baseUrl);

          // Create a single text representation for complex links
          String linkText = element.text.trim();
          TextStyle linkStyle = (elementStyle ?? const TextStyle()).copyWith(
            color: Colors.blue,
            decoration: TextDecoration.combine([
              TextDecoration.underline,
              if (elementStyle?.decoration != null) elementStyle!.decoration!,
            ]),
          );

          return WidgetSpan(
            child: GestureDetector(
              onTap: () => onLinkTap(resolvedUrl),
              child: Text(
                linkText,
                style: linkStyle,
              ),
            ),
          );
        }
      }

      if (children.isEmpty) return null;

      return TextSpan(
        children: children,
        style: elementStyle,
      );
    }
  }

// Helper method to get the style for a specific element
  static TextStyle? _getElementStyle(dom.Element element) {
    switch (element.localName?.toLowerCase()) {
      case 'strong':
      case 'b':
        return const TextStyle(fontWeight: FontWeight.bold);
      case 'em':
      case 'i':
        return const TextStyle(fontStyle: FontStyle.italic);
      case 'u':
        return const TextStyle(decoration: TextDecoration.underline);
      case 'code':
      case 'kbd':
      case 'samp':
        return const TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey,
        );
      case 'var':
        return const TextStyle(
          fontStyle: FontStyle.italic,
          fontFamily: 'serif',
        );
      case 'small':
        return const TextStyle(fontSize: 12);
      case 'big':
        return const TextStyle(fontSize: 18);
      case 'mark':
        return const TextStyle(backgroundColor: Colors.yellow);
      case 'del':
      case 's':
        return const TextStyle(decoration: TextDecoration.lineThrough);
      case 'ins':
        return const TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.green,
        );
      case 'sub':
        return const TextStyle(fontSize: 10);
      case 'sup':
        return const TextStyle(fontSize: 10);
      case 'abbr':
      case 'acronym':
        return const TextStyle(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        );
      case 'cite':
        return const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.blue,
        );
      case 'dfn':
        return const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        );
      default:
        return null;
    }
  }

  static String _resolveUrl(String href, String baseUrl) {
    if (href.startsWith('http://') || href.startsWith('https://')) {
      return href;
    }

    if (href.startsWith('mailto:')) {
      return href; // Keep mailto links as-is
    }

    Uri baseUri = Uri.parse(baseUrl);

    if (href.startsWith('/')) {
      return '${baseUri.scheme}://${baseUri.host}$href';
    }

    if (href.startsWith('#')) {
      return baseUrl; // Fragment links stay on same page
    }

    // Relative URL
    String basePath = baseUri.path;
    if (!basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.lastIndexOf('/') + 1);
    }

    return '${baseUri.scheme}://${baseUri.host}$basePath$href';
  }
}
