import 'package:flutter/material.dart';

import '../../models/city.dart';
import '../../models/weather.dart';
import '../../models/weather_condition.dart';
import '../../utils/formatter.dart';

class CurrentWeatherCard extends StatelessWidget {
  final City city;
  final Weather weather;

  const CurrentWeatherCard({
    super.key,
    required this.city,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = weather.current;
    final kondisi = WeatherCondition.fromCode(
      current.weatherCode,
      isDay: current.isDay,
    );
    final hariIni = weather.daily.isNotEmpty ? weather.daily.first : null;
    final warnaTeks = theme.colorScheme.onPrimaryContainer;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: warnaTeks),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    city.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: warnaTeks,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (city.region.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  city.region,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: warnaTeks.withValues(alpha: 0.8),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(kondisi.icon, size: 72, color: warnaTeks),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatter.temperature(current.temperature),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: warnaTeks,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        kondisi.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: warnaTeks,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Terasa seperti ${Formatter.temperature(current.apparentTemperature)}'
              '${hariIni == null ? '' : '  •  '
                        'Maks ${Formatter.temperature(hariIni.maxTemperature)} / '
                        'Min ${Formatter.temperature(hariIni.minTemperature)}'}',
              style: theme.textTheme.bodyMedium?.copyWith(color: warnaTeks),
            ),
            const SizedBox(height: 4),
            Text(
              '${Formatter.fullDate(current.time)}, pukul '
              '${Formatter.time(current.time)} (waktu setempat)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: warnaTeks.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
