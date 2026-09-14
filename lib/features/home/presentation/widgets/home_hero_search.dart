import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeroSearch extends StatelessWidget {
  const HomeHeroSearch({
    super.key,
    required this.cityName,
    this.onSearchTap,
    this.onQuartierTap,
    this.onExploreTap,
  });

  final String cityName;
  final VoidCallback? onSearchTap;
  final VoidCallback? onQuartierTap;
  final VoidCallback? onExploreTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: textTheme.displayLarge,
            children: [
              const TextSpan(text: 'Trouvez tout ce que vous cherchez à '),
              TextSpan(text: '$cityName.', style: const TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'La marketplace premium pour acheter et vendre en toute confiance.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Barre de recherche
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text('Que recherchez-vous ?', style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Sélecteur de quartier
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onQuartierTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Tous les quartiers', style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // CTA principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onExploreTap,
            child: const Text('Explorer les annonces'),
          ),
        ),
      ],
    );
  }
}
