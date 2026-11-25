import 'package:flutter/material.dart';

import '../../models/city.dart';

class CityTile extends StatelessWidget {
  final City city;
  final IconData leadingIcon;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemove;

  const CityTile({
    super.key,
    required this.city,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.leadingIcon = Icons.location_city,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Icon(leadingIcon, color: theme.colorScheme.onSecondaryContainer),
      ),
      title: Text(city.name),
      subtitle: Text(
        '${city.region.isEmpty ? '' : '${city.region}\n'}'
        '${city.latitude.toStringAsFixed(2)}, '
        '${city.longitude.toStringAsFixed(2)}',
      ),
      isThreeLine: city.region.isNotEmpty,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? Colors.amber.shade700 : null,
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Hapus dari riwayat',
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}
