import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:presient/test1/database/database_controller.dart';
import 'package:presient/test1/model/genre_model.dart';
import 'package:presient/test1/service/service_genre.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/normal_page/home_page.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: HomePage(),
    );
  }
}
