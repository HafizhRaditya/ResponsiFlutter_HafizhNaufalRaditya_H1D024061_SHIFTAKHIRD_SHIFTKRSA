import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../viewmodels/view_status.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/state_views.dart';
import 'widgets/weather_detail_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _bukaPencarian(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  Future<void> _toggleFavorit(BuildContext context, City city) async {
    final messenger = ScaffoldMessenger.of(context);
    final tersimpan = await context.read<FavoriteViewModel>().toggle(city);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            tersimpan
                ? '${city.name} disimpan ke favorit'
                : '${city.name} dihapus dari favorit',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final favoriteVm = context.watch<FavoriteViewModel>();
    final city = weatherVm.city;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Cuaca'),
        actions: [
          if (city != null)
            IconButton(
              tooltip: favoriteVm.isFavorite(city)
                  ? 'Hapus dari favorit'
                  : 'Simpan ke favorit',
              onPressed: () => _toggleFavorit(context, city),
              icon: Icon(
                favoriteVm.isFavorite(city)
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
              ),
            ),
          IconButton(
            tooltip: 'Cari kota',
            onPressed: () => _bukaPencarian(context),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(child: _body(context, weatherVm, favoriteVm)),
    );
  }

  Widget _body(
    BuildContext context,
    WeatherViewModel weatherVm,
    FavoriteViewModel favoriteVm,
  ) {
    final city = weatherVm.city;
    final weather = weatherVm.weather;

    switch (weatherVm.status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        if (weather == null || city == null) {
          return const LoadingView(message: 'Mengambil data cuaca...');
        }
        break;
      case ViewStatus.error:
        return MessageView(
          icon: Icons.cloud_off,
          title: 'Gagal memuat cuaca ${city?.name ?? ''}',
          message: weatherVm.errorMessage,
          actionLabel: 'Coba lagi',
          onAction: weatherVm.refresh,
          isError: true,
        );
      case ViewStatus.empty:
        return MessageView(
          icon: Icons.cloud_queue,
          title: 'Data cuaca kosong',
          message: 'API tidak mengirim data perkiraan untuk ${city?.name}',
          actionLabel: 'Muat ulang',
          onAction: weatherVm.refresh,
        );
      case ViewStatus.success:
        break;
    }

    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: weatherVm.refresh,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (weatherVm.status == ViewStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              CurrentWeatherCard(city: city!, weather: weather!),
              const SizedBox(height: 16),
              WeatherDetailGrid(weather: weather),
              if (favoriteVm.favorites.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Lokasi favorit', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final favorit in favoriteVm.favorites)
                      ChoiceChip(
                        avatar: const Icon(Icons.star_rounded, size: 18),
                        label: Text(favorit.name),
                        selected: favorit == city,
                        onSelected: (_) => weatherVm.selectCity(favorit),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Perkiraan ${weather.daily.length} hari ke depan',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DailyForecastList(
                daily: weather.daily,
                today: weather.daily.first.date,
              ),
              const SizedBox(height: 12),
              Text(
                'Sumber data: Open-Meteo • Zona waktu ${weather.timezone}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
