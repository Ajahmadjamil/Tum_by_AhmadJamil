import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import 'controller.dart';

class PoemFavoriteButton extends StatelessWidget {
  const PoemFavoriteButton({super.key, required this.poetryId});

  final String poetryId;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final favorited = favorites.isFavorite(poetryId);
    return IconButton(
      tooltip: favorited ? 'Unfavorite' : 'Favorite',
      visualDensity: VisualDensity.compact,
      onPressed: () => favorites.toggle(poetryId),
      icon: Icon(
        favorited ? Icons.favorite : Icons.favorite_border,
        color: favorited ? Colors.redAccent : context.colors.textMuted,
      ),
    );
  }
}
