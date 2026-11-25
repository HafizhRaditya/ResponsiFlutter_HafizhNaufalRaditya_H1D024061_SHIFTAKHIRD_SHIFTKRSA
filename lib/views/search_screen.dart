import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/view_status.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/city_tile.dart';
import 'widgets/state_views.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final query = context.read<SearchViewModel>().query;
    _controller.text = query;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<SearchViewModel>().search(value);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    context.read<SearchViewModel>().search(value);
  }

  void _hapusTeks() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    context.read<SearchViewModel>().clearQuery();
  }

  void _pilihKota(City city) {
    context.read<SearchViewModel>().addToHistory(city);
    context.read<WeatherViewModel>().selectCity(city);
    Navigator.of(context).pop();
  }

  Future<void> _toggleFavorit(City city) async {
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
    final searchVm = context.watch<SearchViewModel>();
    final favoriteVm = context.watch<FavoriteViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Lokasi')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _controller,
                    autofocus: searchVm.query.isEmpty,
                    textInputAction: TextInputAction.search,
                    onChanged: _onChanged,
                    onSubmitted: _onSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Ketik nama kota, misal Purwokerto',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus',
                              onPressed: _hapusTeks,
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(child: _hasil(searchVm, favoriteVm)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hasil(SearchViewModel searchVm, FavoriteViewModel favoriteVm) {
    switch (searchVm.status) {
      case ViewStatus.initial:
        return _tersimpan(searchVm, favoriteVm);
      case ViewStatus.loading:
        return const LoadingView(message: 'Mencari lokasi...');
      case ViewStatus.empty:
        return MessageView(
          icon: Icons.location_off_outlined,
          title: 'Kota "${searchVm.query}" tidak ditemukan',
          message: 'Periksa ejaan atau coba nama kota lain',
        );
      case ViewStatus.error:
        return MessageView(
          icon: Icons.wifi_off,
          title: 'Pencarian gagal',
          message: searchVm.errorMessage,
          actionLabel: 'Coba lagi',
          onAction: searchVm.retry,
          isError: true,
        );
      case ViewStatus.success:
        return ListView.separated(
          itemCount: searchVm.results.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final city = searchVm.results[index];
            return CityTile(
              city: city,
              isFavorite: favoriteVm.isFavorite(city),
              onTap: () => _pilihKota(city),
              onToggleFavorite: () => _toggleFavorit(city),
            );
          },
        );
    }
  }

  Widget _tersimpan(SearchViewModel searchVm, FavoriteViewModel favoriteVm) {
    final favorites = favoriteVm.favorites;
    final history = searchVm.history;

    if (favorites.isEmpty && history.isEmpty) {
      return const MessageView(
        icon: Icons.travel_explore,
        title: 'Cari kota untuk melihat cuacanya',
        message: 'Lokasi favorit dan riwayat pencarian akan muncul di sini',
      );
    }

    final theme = Theme.of(context);
    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          _Judul(teks: 'Lokasi favorit', style: theme.textTheme.titleSmall),
          for (final city in favorites)
            CityTile(
              city: city,
              leadingIcon: Icons.star_rounded,
              isFavorite: true,
              onTap: () => _pilihKota(city),
              onToggleFavorite: () => _toggleFavorit(city),
            ),
        ],
        if (history.isNotEmpty) ...[
          _Judul(
            teks: 'Riwayat pencarian',
            style: theme.textTheme.titleSmall,
            aksi: TextButton(
              onPressed: searchVm.clearHistory,
              child: const Text('Hapus semua'),
            ),
          ),
          for (final city in history)
            CityTile(
              city: city,
              leadingIcon: Icons.history,
              isFavorite: favoriteVm.isFavorite(city),
              onTap: () => _pilihKota(city),
              onToggleFavorite: () => _toggleFavorit(city),
              onRemove: () => searchVm.removeFromHistory(city),
            ),
        ],
      ],
    );
  }
}

class _Judul extends StatelessWidget {
  final String teks;
  final TextStyle? style;
  final Widget? aksi;

  const _Judul({required this.teks, this.style, this.aksi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(child: Text(teks, style: style)),
          ?aksi,
        ],
      ),
    );
  }
}
