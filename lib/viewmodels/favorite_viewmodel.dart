import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../services/local_storage_service.dart';

class FavoriteViewModel extends ChangeNotifier {
  final LocalStorageService _storage;

  FavoriteViewModel(this._storage);

  List<City> _favorites = [];

  List<City> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    _favorites = await _storage.getFavorites();
    notifyListeners();
  }

  bool isFavorite(City city) => _favorites.contains(city);

  Future<bool> toggle(City city) async {
    final tersimpan = !isFavorite(city);
    if (tersimpan) {
      _favorites = [..._favorites, city];
    } else {
      _favorites = _favorites.where((item) => item != city).toList();
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
    return tersimpan;
  }
}
