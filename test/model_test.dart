import 'package:flutter_test/flutter_test.dart';
import 'package:info_cuaca/models/city.dart';
import 'package:info_cuaca/models/weather.dart';
import 'package:info_cuaca/models/weather_condition.dart';
import 'package:info_cuaca/utils/formatter.dart';

import 'fake_api.dart';

void main() {
  test('City.fromJson membaca hasil Geocoding API', () {
    final json = (geocodingPurwokerto['results'] as List).first;
    final city = City.fromJson(json as Map<String, dynamic>);

    expect(city.id, 1630328);
    expect(city.name, 'Kota Purwokerto');
    expect(city.region, 'Jawa Tengah, Indonesia');
    expect(City.fromJson(city.toJson()), city);
  });

  test('Weather.fromJson membaca current dan daily', () {
    final weather = Weather.fromJson(forecast());

    expect(weather.timezone, 'Asia/Jakarta');
    expect(weather.current.temperature, 27.5);
    expect(weather.current.humidity, 85);
    expect(weather.current.apparentTemperature, 33.3);
    expect(weather.current.windSpeed, 5.2);
    expect(weather.daily, hasLength(3));
    expect(weather.daily.first.maxTemperature, 28.3);
    expect(weather.todayRainChance, 100);
    expect(weather.daily.last.precipitationProbabilityMax, isNull);
  });

  test('Kode cuaca WMO diubah menjadi teks bahasa Indonesia', () {
    expect(WeatherCondition.fromCode(0).description, 'Cerah');
    expect(WeatherCondition.fromCode(61).description, 'Hujan ringan');
    expect(WeatherCondition.fromCode(95).description, 'Badai petir');
    expect(WeatherCondition.fromCode(1234).description, 'Tidak diketahui');
  });

  test('Formatter menampilkan nama hari', () {
    final hariIni = DateTime(2026, 11, 25);
    expect(Formatter.dayName(hariIni, today: hariIni), 'Hari ini');
    expect(Formatter.dayName(DateTime(2026, 11, 26), today: hariIni), 'Besok');
    expect(Formatter.dayName(DateTime(2026, 11, 27), today: hariIni), 'Jumat');
  });
}
