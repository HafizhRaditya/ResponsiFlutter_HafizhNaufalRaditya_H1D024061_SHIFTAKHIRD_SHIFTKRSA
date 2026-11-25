import 'package:flutter_test/flutter_test.dart';
import 'package:info_cuaca/services/local_storage_service.dart';
import 'package:info_cuaca/services/weather_api_service.dart';
import 'package:info_cuaca/viewmodels/favorite_viewmodel.dart';
import 'package:info_cuaca/viewmodels/search_viewmodel.dart';
import 'package:info_cuaca/viewmodels/view_status.dart';
import 'package:info_cuaca/viewmodels/weather_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_api.dart';

void main() {
  late FakeOpenMeteo server;
  late WeatherApiService api;
  late LocalStorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = FakeOpenMeteo();
    api = WeatherApiService(client: server.client);
    storage = LocalStorageService();
  });

  test('WeatherViewModel memuat cuaca kota default lewat GET', () async {
    final vm = WeatherViewModel(api, storage);
    await vm.init();

    expect(vm.status, ViewStatus.success);
    expect(vm.city, WeatherViewModel.defaultCity);
    expect(vm.weather!.current.temperature, 27.5);
    final uri = server.requests.single;
    expect(uri.path, '/v1/forecast');
    expect(uri.queryParameters['timezone'], 'auto');
    expect(uri.queryParameters['current'], contains('temperature_2m'));
    expect(
      uri.queryParameters['daily'],
      contains('precipitation_probability_max'),
    );
  });

  test('WeatherViewModel menyimpan kota terakhir', () async {
    final cari = SearchViewModel(api, storage);
    await cari.search('Bandung');
    final vm = WeatherViewModel(api, storage);
    await vm.selectCity(cari.results.first);

    final vmBaru = WeatherViewModel(api, storage);
    await vmBaru.init();
    expect(vmBaru.city!.name, 'Bandung');
    expect(vmBaru.weather!.current.temperature, 22.4);
  });

  test('WeatherViewModel masuk status error saat offline', () async {
    server.offline = true;
    final vm = WeatherViewModel(api, storage);
    await vm.init();

    expect(vm.status, ViewStatus.error);
    expect(vm.errorMessage, 'Tidak ada koneksi internet');
  });

  test('SearchViewModel: hasil, kosong, dan error', () async {
    final vm = SearchViewModel(api, storage);

    await vm.search('Purwokerto');
    expect(vm.status, ViewStatus.success);
    expect(vm.results.single.name, 'Kota Purwokerto');
    expect(server.requests.last.path, '/v1/search');

    await vm.search('xqzzqx');
    expect(vm.status, ViewStatus.empty);

    await vm.search('   ');
    expect(vm.status, ViewStatus.initial);

    server.offline = true;
    await vm.search('Bandung');
    expect(vm.status, ViewStatus.error);
  });

  test('Riwayat dan favorit tersimpan di local storage', () async {
    final cari = SearchViewModel(api, storage);
    await cari.search('Purwokerto');
    final purwokerto = cari.results.first;
    await cari.search('Bandung');
    final bandung = cari.results.first;

    await cari.addToHistory(purwokerto);
    await cari.addToHistory(bandung);
    await cari.addToHistory(purwokerto);
    final favorit = FavoriteViewModel(storage);
    expect(await favorit.toggle(bandung), isTrue);

    final cariBaru = SearchViewModel(api, storage);
    await cariBaru.loadHistory();
    final favoritBaru = FavoriteViewModel(storage);
    await favoritBaru.load();

    expect(cariBaru.history.map((c) => c.name), ['Kota Purwokerto', 'Bandung']);
    expect(favoritBaru.isFavorite(bandung), isTrue);
    expect(await favoritBaru.toggle(bandung), isFalse);
    expect(favoritBaru.favorites, isEmpty);
  });
}
