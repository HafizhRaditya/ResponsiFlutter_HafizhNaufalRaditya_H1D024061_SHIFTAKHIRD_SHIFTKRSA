import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_status.dart';

class WeatherViewModel extends ChangeNotifier {
  static const defaultCity = City(
    id: 1630328,
    name: 'Purwokerto',
    latitude: -7.42139,
    longitude: 109.23444,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
  );

  final WeatherApiService _api;
  final LocalStorageService _storage;

  WeatherViewModel(this._api, this._storage);

  City? _city;
  Weather? _weather;
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  int _requestId = 0;

  City? get city => _city;
  Weather? get weather => _weather;
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    final saved = await _storage.getLastCity();
    await selectCity(saved ?? defaultCity, save: false);
  }

  Future<void> selectCity(City city, {bool save = true}) async {
    _city = city;
    if (save) await _storage.saveLastCity(city);
    await refresh();
  }

  Future<void> refresh() async {
    final city = _city;
    if (city == null) return;
    final id = ++_requestId;
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getWeather(city);
      if (id != _requestId) return;
      _weather = result;
      _status = result.daily.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } catch (e) {
      if (id != _requestId) return;
      _weather = null;
      _errorMessage = e is ApiException ? e.message : 'Gagal memuat data cuaca';
      _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
