import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_status.dart';

class SearchViewModel extends ChangeNotifier {
  static const maxHistory = 8;

  final WeatherApiService _api;
  final LocalStorageService _storage;

  SearchViewModel(this._api, this._storage);

  String _query = '';
  List<City> _results = [];
  List<City> _history = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  int _requestId = 0;

  String get query => _query;
  List<City> get results => List.unmodifiable(_results);
  List<City> get history => List.unmodifiable(_history);
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _history = await _storage.getHistory();
    notifyListeners();
  }

  Future<void> search(String keyword) async {
    _query = keyword.trim();
    final id = ++_requestId;

    if (_query.isEmpty) {
      _results = [];
      _status = ViewStatus.initial;
      notifyListeners();
      return;
    }

    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final cities = await _api.searchCity(_query);
      if (id != _requestId) return;
      _results = cities;
      _status = cities.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } catch (e) {
      if (id != _requestId) return;
      _results = [];
      _errorMessage = e is ApiException ? e.message : 'Pencarian gagal';
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> retry() => search(_query);

  void clearQuery() {
    search('');
  }

  Future<void> addToHistory(City city) async {
    _history = [
      city,
      ..._history.where((item) => item != city),
    ].take(maxHistory).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> removeFromHistory(City city) async {
    _history = _history.where((item) => item != city).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.saveHistory(_history);
  }
}
