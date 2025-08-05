// /test/core/http_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bones/core/http_service.dart';

void main() {
  group('HttpService', () {
    test('handles URL normalization through fetchUrl', () async {
      // Test that URLs without protocol get normalized
      // Note: This will make actual network calls, so we test with a mock or
      // expect network exceptions for invalid domains
      
      try {
        await HttpService.fetchUrl('invalid-domain-that-does-not-exist.xyz');
        fail('Should have thrown an HttpException');
      } catch (e) {
        expect(e, isA<HttpException>());
        // The error message should indicate it tried to fetch https://invalid-domain...
        expect(e.toString(), contains('https://'));
      }
    });

    test('throws HttpException on completely invalid input', () async {
      expect(
        () => HttpService.fetchUrl(''),
        throwsA(isA<HttpException>()),
      );
      
      expect(
        () => HttpService.fetchUrl('not-a-url-at-all'),
        throwsA(isA<HttpException>()),
      );
    });

    test('handles timeout correctly', () async {
      // Test with a non-routable IP to trigger timeout
      expect(
        () => HttpService.fetchUrl('http://10.255.255.1'),
        throwsA(isA<HttpException>()),
      );
    });
  });
}