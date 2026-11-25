import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/weather.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class WeatherApiService {
  static const _geocodingHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<City>> searchCity(String name) async {
    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': name,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });
    final json = await _get(uri);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((item) => City.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Weather> getWeather(City city) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m,is_day',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _get(uri);
    return Weather.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw ApiException(
          'Server cuaca sedang bermasalah (kode ${response.statusCode})',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet');
    } on http.ClientException {
      throw const ApiException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons, coba lagi');
    } on FormatException {
      throw const ApiException('Data dari server tidak dapat dibaca');
    }
  }
}
