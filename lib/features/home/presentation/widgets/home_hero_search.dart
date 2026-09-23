import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeroSearch extends StatelessWidget {
  const HomeHeroSearch({
    super.key,
    required this.headlineLocation,
    this.selectedLocationLabel,
    this.onSearchTap,
    this.onQuartierTap,
    this.onExploreTap,
  });

  /// Toujours non-null : "Côte d'Ivoire" par défaut, ou le nom de la
  /// ville/commune choisie une fois qu'un filtre est actif.
  final String headlineLocation;

  /// Null = "Toutes les localités" (affiché tel quel dans le sélecteur).
  final String? selectedLocationLabel;

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
              const TextSpan(text: 'Trouvez tout ce que vous cherchez en '),
              TextSpan(text: '$headlineLocation.', style: const TextStyle(color: AppColors.primary)),
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

        // Sélecteur de localisation
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
                  Icon(Icons.map_outlined, size: 20, color: selectedLocationLabel != null ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedLocationLabel ?? 'Toutes les localités',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: selectedLocationLabel != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

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
