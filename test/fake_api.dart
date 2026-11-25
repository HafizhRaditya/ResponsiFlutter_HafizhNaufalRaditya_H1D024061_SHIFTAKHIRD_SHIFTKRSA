import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const geocodingPurwokerto = {
  'results': [
    {
      'id': 1630328,
      'name': 'Kota Purwokerto',
      'latitude': -7.42139,
      'longitude': 109.23444,
      'country': 'Indonesia',
      'admin1': 'Jawa Tengah',
    },
  ],
};

const geocodingBandung = {
  'results': [
    {
      'id': 1650357,
      'name': 'Bandung',
      'latitude': -6.90389,
      'longitude': 107.61861,
      'country': 'Indonesia',
      'admin1': 'Jawa Barat',
    },
  ],
};

Map<String, dynamic> forecast({double suhu = 27.5, int kode = 3}) => {
  'timezone': 'Asia/Jakarta',
  'current': {
    'time': '2026-11-25T12:15',
    'temperature_2m': suhu,
    'relative_humidity_2m': 85,
    'apparent_temperature': 33.3,
    'precipitation': 0.1,
    'weather_code': kode,
    'wind_speed_10m': 5.2,
    'is_day': 1,
  },
  'daily': {
    'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
    'weather_code': [81, 95, 0],
    'temperature_2m_max': [28.3, 28.5, 30.3],
    'temperature_2m_min': [24.5, 23.7, 24.0],
    'precipitation_probability_max': [100, 90, null],
  },
};

class FakeOpenMeteo {
  final List<Uri> requests = [];
  bool offline = false;

  MockClient get client => MockClient((request) async {
    requests.add(request.url);
    if (offline) throw http.ClientException('offline');
    if (request.url.host == 'geocoding-api.open-meteo.com') {
      final nama = (request.url.queryParameters['name'] ?? '').toLowerCase();
      if (nama.contains('purwokerto')) {
        return http.Response(jsonEncode(geocodingPurwokerto), 200);
      }
      if (nama.contains('bandung')) {
        return http.Response(jsonEncode(geocodingBandung), 200);
      }
      return http.Response(jsonEncode({'generationtime_ms': 0.1}), 200);
    }
    final lat = double.parse(request.url.queryParameters['latitude']!);
    return http.Response(
      jsonEncode(
        forecast(suhu: lat < -7 ? 27.5 : 22.4, kode: lat < -7 ? 3 : 61),
      ),
      200,
    );
  });
}
