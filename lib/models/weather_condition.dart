import 'package:flutter/material.dart';

class WeatherCondition {
  final String description;
  final IconData icon;

  const WeatherCondition(this.description, this.icon);

  factory WeatherCondition.fromCode(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return WeatherCondition(
          'Cerah',
          isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        );
      case 1:
        return WeatherCondition(
          'Cerah berawan',
          isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
        );
      case 2:
        return const WeatherCondition('Berawan sebagian', Icons.cloud_queue);
      case 3:
        return const WeatherCondition('Mendung', Icons.cloud);
      case 45:
      case 48:
        return const WeatherCondition('Berkabut', Icons.foggy);
      case 51:
      case 53:
      case 55:
        return const WeatherCondition('Gerimis', Icons.grain);
      case 56:
      case 57:
        return const WeatherCondition('Gerimis beku', Icons.ac_unit);
      case 61:
        return const WeatherCondition(
          'Hujan ringan',
          Icons.water_drop_outlined,
        );
      case 63:
        return const WeatherCondition('Hujan sedang', Icons.water_drop);
      case 65:
        return const WeatherCondition('Hujan lebat', Icons.water_drop);
      case 66:
      case 67:
        return const WeatherCondition('Hujan beku', Icons.ac_unit);
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherCondition('Salju', Icons.ac_unit);
      case 80:
        return const WeatherCondition('Hujan lokal ringan', Icons.umbrella);
      case 81:
        return const WeatherCondition('Hujan lokal sedang', Icons.umbrella);
      case 82:
        return const WeatherCondition('Hujan lokal lebat', Icons.umbrella);
      case 85:
      case 86:
        return const WeatherCondition('Hujan salju', Icons.ac_unit);
      case 95:
        return const WeatherCondition('Badai petir', Icons.thunderstorm);
      case 96:
      case 99:
        return const WeatherCondition(
          'Badai petir disertai es',
          Icons.thunderstorm,
        );
      default:
        return const WeatherCondition('Tidak diketahui', Icons.help_outline);
    }
  }
}
