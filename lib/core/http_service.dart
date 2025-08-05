// /lib/core/http_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpService {
  static const int _maxRedirects = 5;
  static const Duration _timeout = Duration(seconds: 30);

  static Future<HttpResponse> fetchUrl(String url) async {
    try {
      String normalizedUrl = _normalizeUrl(url);
      
      http.Response response = await _fetchWithRedirects(normalizedUrl);
      
      return HttpResponse(
        url: normalizedUrl,
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
      );
    } on SocketException {
      throw HttpException('No internet connection');
    } on http.ClientException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } catch (e) {
      throw HttpException('Failed to fetch URL: $e');
    }
  }

  static String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  static Future<http.Response> _fetchWithRedirects(String url) async {
    String currentUrl = url;
    int redirectCount = 0;

    while (redirectCount < _maxRedirects) {
      final response = await http.get(
        Uri.parse(currentUrl),
        headers: {
          'User-Agent': 'Bones-Browser/1.0.0',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(_timeout);

      if (response.statusCode >= 300 && response.statusCode < 400) {
        String? location = response.headers['location'];
        if (location != null) {
          if (location.startsWith('http')) {
            currentUrl = location;
          } else if (location.startsWith('/')) {
            Uri uri = Uri.parse(currentUrl);
            currentUrl = '${uri.scheme}://${uri.host}$location';
          } else {
            Uri uri = Uri.parse(currentUrl);
            String path = uri.path.substring(0, uri.path.lastIndexOf('/') + 1);
            currentUrl = '${uri.scheme}://${uri.host}$path$location';
          }
          redirectCount++;
          continue;
        }
      }
      
      return response;
    }
    
    throw HttpException('Too many redirects');
  }
}

class HttpResponse {
  final String url;
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final bool isSuccess;

  HttpResponse({
    required this.url,
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.isSuccess,
  });
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => message;
}