import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_cuaca/main.dart';
import 'package:info_cuaca/services/local_storage_service.dart';
import 'package:info_cuaca/services/weather_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_api.dart';

void main() {
  late FakeOpenMeteo server;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = FakeOpenMeteo();
  });

  Future<void> bukaAplikasi(WidgetTester tester) async {
    await tester.pumpWidget(
      InfoCuacaApp(
        api: WeatherApiService(client: server.client),
        storage: LocalStorageService(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home menampilkan cuaca dari API', (tester) async {
    await bukaAplikasi(tester);

    expect(find.text('Purwokerto'), findsOneWidget);
    expect(find.text('28°'), findsOneWidget);
    expect(find.text('Mendung'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('5.2 km/j'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
    expect(find.text('Perkiraan 3 hari ke depan'), findsOneWidget);
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Besok'), findsOneWidget);
  });

  testWidgets('Cari kota, simpan favorit, lalu tampilkan cuacanya', (
    tester,
  ) async {
    await bukaAplikasi(tester);
    await tester.tap(find.byTooltip('Cari kota'));
    await tester.pumpAndSettle();
    expect(find.text('Cari kota untuk melihat cuacanya'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kotaxyz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Kota "kotaxyz" tidak ditemukan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Bandung');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Jawa Barat, Indonesia\n-6.90, 107.62'), findsOneWidget);

    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Bandung disimpan ke favorit'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Bandung'));
    await tester.pumpAndSettle();
    expect(find.text('Info Cuaca'), findsOneWidget);
    expect(find.text('22°'), findsOneWidget);
    expect(find.text('Hujan ringan'), findsOneWidget);
    expect(find.text('Lokasi favorit'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_city'), contains('Bandung'));
    expect(prefs.getStringList('favorite_cities'), hasLength(1));
    expect(prefs.getStringList('search_history'), hasLength(1));
  });

  testWidgets('Data tersimpan muncul lagi saat aplikasi dibuka', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'last_city':
          '{"id":1650357,"name":"Bandung","latitude":-6.90389,'
          '"longitude":107.61861,"country":"Indonesia","admin1":"Jawa Barat"}',
    });
    await bukaAplikasi(tester);

    expect(find.text('Bandung'), findsOneWidget);
    expect(find.text('22°'), findsOneWidget);
  });

  testWidgets('Error saat offline bisa dicoba lagi', (tester) async {
    server.offline = true;
    await bukaAplikasi(tester);

    expect(find.text('Gagal memuat cuaca Purwokerto'), findsOneWidget);
    expect(find.text('Tidak ada koneksi internet'), findsOneWidget);

    server.offline = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('28°'), findsOneWidget);
  });
}
