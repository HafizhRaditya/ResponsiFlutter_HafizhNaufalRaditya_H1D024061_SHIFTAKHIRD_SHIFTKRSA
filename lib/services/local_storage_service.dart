import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';

class LocalStorageService {
  static const _favoritesKey = 'favorite_cities';
  static const _historyKey = 'search_history';
  static const _lastCityKey = 'last_city';

  Future<List<City>> getFavorites() => _getCities(_favoritesKey);

  Future<void> saveFavorites(List<City> cities) =>
      _saveCities(_favoritesKey, cities);

  Future<List<City>> getHistory() => _getCities(_historyKey);

  Future<void> saveHistory(List<City> cities) =>
      _saveCities(_historyKey, cities);

  Future<City?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lastCityKey);
    if (data == null) return null;
    return City.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> saveLastCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, jsonEncode(city.toJson()));
  }

  Future<List<City>> _getCities(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data
        .map((item) => City.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCities(String key, List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      cities.map((city) => jsonEncode(city.toJson())).toList(),
    );
  }
}
