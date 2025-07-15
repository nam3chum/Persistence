import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.purple[600]),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final isDark = themeNotifier.value == ThemeMode.dark;
            final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
            await ThemePreference().saveTheme(newMode == ThemeMode.dark);
            themeNotifier.value = newMode;
          },
          child: Text('Chuyển theme'),
        ),
      ),
    );
  }
}

class ThemePreference {
  static const _key = 'isDarkMode';

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
