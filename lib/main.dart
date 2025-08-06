import 'package:flutter/material.dart';
import 'pages/url_prompt_page.dart';

void main() {
  runApp(const BonesApp());
}

class BonesApp extends StatefulWidget {
  const BonesApp({super.key});

  @override
  State<BonesApp> createState() => _BonesAppState();
}

class _BonesAppState extends State<BonesApp> {
  final String _uiFontFamily = 'FiraCode';
  final double _uiFontSize = 16;

  String _fontFamily = 'FiraCode';
  double _fontSize = 16;

  static const Color accentTeal = Color(0xFF008080);

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: accentTeal,
      colorScheme: ColorScheme.dark(
        primary: accentTeal,
        secondary: accentTeal,
        outline: accentTeal,
      ),
      fontFamily: _uiFontFamily,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: accentTeal,
        iconTheme: IconThemeData(color: accentTeal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTeal,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentTeal,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentTeal,
        thumbColor: accentTeal,
        overlayColor: accentTeal,
        inactiveTrackColor: Colors.grey,
      ),
    );

    return MaterialApp(
      title: 'bones',
      theme: themeData,
      darkTheme: themeData,
      themeMode: ThemeMode.dark, // always dark
      home: URLPromptPage(
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        onFontChange: (fam) => setState(() => _fontFamily = fam),
        onFontSizeChange: (size) =>
            setState(() => _fontSize = size.clamp(10, 20)),
        uiFontFamily: _uiFontFamily,
        uiFontSize: _uiFontSize,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}