// /lib/models/page_state.dart
class PageState {
  final String url;
  final String title;
  final String content;
  final int scrollPosition;
  final DateTime timestamp;

  PageState({
    required this.url,
    required this.title,
    required this.content,
    this.scrollPosition = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  PageState copyWith({
    String? url,
    String? title,
    String? content,
    int? scrollPosition,
    DateTime? timestamp,
  }) {
    return PageState(
      url: url ?? this.url,
      title: title ?? this.title,
      content: content ?? this.content,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'content': content,
      'scrollPosition': scrollPosition,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory PageState.fromMap(Map<String, dynamic> map) {
    return PageState(
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      scrollPosition: map['scrollPosition'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}

class BrowserHistory {
  final List<PageState> _history = [];
  int _currentIndex = -1;

  void push(PageState page) {
    // Remove any forward history if we're not at the end
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    
    _history.add(page);
    _currentIndex = _history.length - 1;
  }

  PageState? get current {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  bool get canGoBack => _currentIndex > 0;
  bool get canGoForward => _currentIndex < _history.length - 1;

  PageState? goBack() {
    if (canGoBack) {
      _currentIndex--;
      return current;
    }
    return null;
  }

  PageState? goForward() {
    if (canGoForward) {
      _currentIndex++;
      return current;
    }
    return null;
  }

  List<PageState> get pages => List.unmodifiable(_history);
  
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}