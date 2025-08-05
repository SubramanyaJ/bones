// /lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/url_prompt_page.dart';
import 'core/app_theme.dart';

void main() {
  runApp(const BonesApp());
}

class BonesApp extends StatefulWidget {
  const BonesApp({super.key});

  @override
  State<BonesApp> createState() => _BonesAppState();
}

class _BonesAppState extends State<BonesApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bones Browser',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: URLPromptPage(onThemeToggle: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}