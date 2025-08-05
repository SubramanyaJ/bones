bones
A Flutter Text-Only Browser - Project Blueprint
Internal working specification for a minimalist, no-JavaScript browser built with Flutter.

1 PURPOSE

Create an Android text-only browser that:
- Requests a URL at startup, fetches the raw HTTP response, strips/ignores JavaScript, and renders HTML as readable text.
- Emulates CLI tools such as w3m, lynx, or curl, while taking advantage of Flutter's modern UI toolkit.
- Uses minimal system resources

2 SCOPE

2.1 In-Scope MVP
- URL entry, basic history back/forward, and reload.
- HTTP/HTTPS GET, manual redirect handling.
- HTML to Flutter widget rendering for:
  - Headings h1-h6, paragraphs, lists, anchors, tables, images optional toggle.
  - Basic inline formatting: strong, em, code, pre.
- Link navigation inside the rendered page tap to open.
- Dark/light theme toggle.
- Graceful error states network timeouts, 4xx/5xx.

2.2 Out of Scope initial release
- JavaScript execution, CSS layout engine, audio/video, authentication flows, cookies, downloads, service-workers.

3 TECHNOLOGY STACK

UI & State: Flutter 3.x Dart >= 3 - Multi-platform, reactive widgets
HTTP: package:http - Simple, lightweight HTTP client
HTML Parsing: package:html - DOM parsing without JS
State Management: ValueNotifier + InheritedWidget MVP can swap to provider later - Keep footprint minimal
Persistence: shared_preferences history, settings - Key-value, no DB overhead
Testing: flutter_test, mocktail, golden_toolkit - Unit, widget, and golden tests
CI: GitHub Actions flutter test to flutter build - Automated checks per PR

4 HIGH-LEVEL ARCHITECTURE

UI Layer - Material/Cupertino widgets
View-Model - Navigation stack, user prefs
Rendering Service - DOM to RichText / Widget tree
Network - HTTP client, caching stub

Separation of concerns keeps networking, parsing, and UI independent for easier testing and future feature swaps.

5 USER FLOW

1. Launch to URLPromptPage
   - TextField focus on load + Go button.
2. Fetch
   - Validate scheme prepend https:// if missing.
   - Show CircularProgressIndicator.
3. RenderPage
   - Convert HTML to DOM to widget hierarchy.
   - Tap on anchor pushes new page onto Navigator.
4. AppBar controls: Back Forward Refresh Theme Settings.

6 HTML-TO-WIDGET MAPPING RULES

h1-h6: Text with TextStyle fontSize
p: SelectableText
a[href]: GestureDetector + TextSpan
ul/ol: Column of Row bullet icon + text
img: Optional Image.network if Images ON
table: Table widget no colspan
pre: SelectableText with monospace

Fallback: any unhandled node renders as Text unsupported.

7 KEY MODULES & FILE STRUCTURE

lib/
main.dart - app bootstrap
core/
  http_service.dart - fetch & redirect logic
  parser_service.dart - HTML to DOM
  render_service.dart - DOM to Widget list
models/
  page_state.dart - URL, history index, scroll pos
pages/
  url_prompt_page.dart
  render_page.dart
widgets/
  paragraph.dart
  heading.dart
  link_text.dart
  list_block.dart
utils/
  html_extensions.dart - sugar helpers
assets/
test/

8 DEVELOPMENT WORKFLOW

1. flutter create text_browser
2. Add dependencies in pubspec.yaml.
3. Implement network service write unit tests.
4. Implement parser + renderer; create golden tests for sample pages.
5. Build minimal UI; wire navigation & history.
6. Add persistence theme & history.
7. Performance profiling flutter profile.
8. Package for Android apk, iOS ipa, desktop, web.

9 TESTING STRATEGY

Unit tests for:
- URL sanitization, redirect logic, HTML parsing edge cases.
Widget tests for:
- Rendering of sample HTML snippets golden images.
Integration test:
- Launch enter example.com verify first h1 rendered.

10 PERFORMANCE & MEMORY

- Stream HTML chunks to parser to avoid large strings.
- Use ListView.builder for long pages lazy build.
- Cache last N pages memory with LRU eviction.

11 SECURITY & PRIVACY

- Only outbound GETs; no cookie storage MVP.
- Validate SSL certificates by default.
- Copy link and Open externally actions behind long-press.

12 CI/CD

GitHub Actions
- flutter pub get
- flutter analyze
- flutter test --coverage
- flutter build apk --release

Artifacts uploaded for manual QA.

13 ROADMAP POST-MVP

- Toggle image loading per site.
- Basic CSS color & font support no layout.
- Offline reading download & store pages.
- Custom scrollbar, search-in-page.
- Plug-in architecture for user scripts still JS-free.

14 APPENDIX

- Flutter architectural layers explanation.
- HTTP status code handling table.
- Sample DOM fixture files for tests /test/fixtures/.