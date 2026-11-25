import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/favorite_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    InfoCuacaApp(api: WeatherApiService(), storage: LocalStorageService()),
  );
}

class InfoCuacaApp extends StatelessWidget {
  final WeatherApiService api;
  final LocalStorageService storage;

  const InfoCuacaApp({super.key, required this.api, required this.storage});

  ThemeData _tema(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: brightness,
    );
    final dasar = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
    );
    return dasar.copyWith(
      textTheme: dasar.textTheme.copyWith(
        titleLarge: dasar.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: dasar.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: dasar.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(api, storage)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(api, storage)..loadHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteViewModel(storage)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Info Cuaca',
        debugShowCheckedModeBanner: false,
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
