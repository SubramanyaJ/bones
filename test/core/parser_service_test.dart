// /test/core/parser_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bones/core/parser_service.dart';

void main() {
  group('ParserService', () {
    test('parses HTML correctly', () {
      const html = '<html><body><h1>Test</h1></body></html>';
      final document = ParserService.parseHtml(html);
      
      expect(document.querySelector('h1')?.text, 'Test');
    });

    test('extracts title correctly', () {
      const html = '<html><head><title>Test Page</title></head><body></body></html>';
      final document = ParserService.parseHtml(html);
      
      expect(ParserService.extractTitle(document), 'Test Page');
    });

    test('strips scripts and styles', () {
      const html = '''
        <html>
          <head><style>body { color: red; }</style></head>
          <body>
            <script>alert('test');</script>
            <h1>Content</h1>
          </body>
        </html>
      ''';
      
      final cleaned = ParserService.stripScriptsAndStyles(html);
      expect(cleaned.contains('<script>'), false);
      expect(cleaned.contains('<style>'), false);
      expect(cleaned.contains('<h1>Content</h1>'), true);
    });
  });
}