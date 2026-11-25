import 'package:flutter/material.dart';

import '../../models/weather.dart';
import '../../models/weather_condition.dart';
import '../../utils/formatter.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> daily;
  final DateTime today;

  const DailyForecastList({
    super.key,
    required this.daily,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < daily.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _ForecastTile(forecast: daily[i], today: today),
          ],
        ],
      ),
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final DateTime today;

  const _ForecastTile({required this.forecast, required this.today});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kondisi = WeatherCondition.fromCode(forecast.weatherCode);
    final peluang = forecast.precipitationProbabilityMax;

    return ListTile(
      leading: Icon(kondisi.icon, color: theme.colorScheme.primary),
      title: Text(
        Formatter.dayName(forecast.date, today: today),
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        '${Formatter.shortDate(forecast.date)} • ${kondisi.description}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${Formatter.temperature(forecast.maxTemperature)} / '
            '${Formatter.temperature(forecast.minTemperature)}',
            style: theme.textTheme.titleSmall,
          ),
          if (peluang != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.umbrella_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text('$peluang%', style: theme.textTheme.bodySmall),
              ],
            ),
        ],
      ),
    );
  }
}
