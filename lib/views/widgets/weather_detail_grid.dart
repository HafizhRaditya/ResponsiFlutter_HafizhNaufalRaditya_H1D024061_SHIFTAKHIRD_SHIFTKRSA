import 'package:flutter/material.dart';

import '../../models/weather.dart';

class WeatherDetailGrid extends StatelessWidget {
  final Weather weather;

  const WeatherDetailGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final peluang = weather.todayRainChance;
    final items = [
      _DetailItem(
        Icons.water_drop_outlined,
        'Kelembapan',
        '${current.humidity}%',
      ),
      _DetailItem(
        Icons.air,
        'Kecepatan angin',
        '${current.windSpeed.toStringAsFixed(1)} km/j',
      ),
      _DetailItem(
        Icons.umbrella_outlined,
        'Peluang hujan',
        peluang == null ? '-' : '$peluang%',
      ),
      _DetailItem(
        Icons.grain,
        'Curah hujan',
        '${current.precipitation.toStringAsFixed(1)} mm',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final kolom = constraints.maxWidth >= 560 ? 4 : 2;
        final lebar = (constraints.maxWidth - (kolom - 1) * 12) / kolom;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: lebar,
                child: _DetailTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem(this.icon, this.label, this.value);
}

class _DetailTile extends StatelessWidget {
  final _DetailItem item;

  const _DetailTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(item.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
