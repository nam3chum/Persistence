import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:presient/test1/database/database_controller.dart';
import 'package:presient/test1/model/genre_model.dart';
import 'package:presient/test1/service/service_genre.dart';
import 'package:presient/test1/ui/normal_page/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/normal_page/home_page.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  final dbController = DatabaseController();
  Future<bool> isFirstTimeLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final launched = prefs.getBool('hasLaunched') ?? false;
    if (!launched) {
      prefs.setBool('hasLaunched', true);
    }
    return !launched;
  }

  WidgetsFlutterBinding.ensureInitialized();
  final isFirstLaunch = await isFirstTimeLaunch();

  if (isFirstLaunch) {
    final List<Genre> genresFromApi = await ApiGenreService(Dio()).getGenres();
    await dbController.insertGenres(genresFromApi);
  }

  final isDark = await ThemePreference().getTheme();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(MyApp(isDark));
}

class MyApp extends StatelessWidget {
  final bool isDark;

  const MyApp(this.isDark, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: HomePage(),
        );
      },
    );
  }
}
