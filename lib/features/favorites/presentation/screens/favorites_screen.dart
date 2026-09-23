import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/favorite_overrides_provider.dart';
import '../../../home/presentation/widgets/listing_card.dart';
import '../../../home/presentation/widgets/trok_bottom_nav.dart';
import '../providers/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        break; // déjà ici
      case 2:
        context.push('/create-listing'); // flux à part, reste en push
      case 3:
        context.go('/messages');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(myFavoritesProvider);
    final overrides = ref.watch(favoriteOverridesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: TrokBottomNav(currentIndex: 1, onTap: (index) => _handleNavTap(context, index)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Favoris', style: textTheme.displayMedium),
            ),
            Expanded(
              child: favoritesAsync.when(
                data: (paginated) {
                  final visible = paginated.items
                      .where((listing) => overrides[listing.id] ?? listing.isFavoritedByViewer)
                      .toList();

                  if (visible.isEmpty) return const _EmptyFavorites();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(myFavoritesProvider);
                      await ref.read(myFavoritesProvider.future);
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final listing = visible[index];
                        return ListingCard(
                          listing: listing,
                          isFavorited: overrides[listing.id] ?? listing.isFavoritedByViewer,
                          onTap: () => context.push('/listing/${listing.id}'),
                          onFavoriteTap: () => ref.read(favoriteOverridesProvider.notifier).toggle(listing),
                        );
                      },
                    ),
                  );
                },
                loading: () => const _FavoritesShimmerGrid(),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Impossible de charger tes favoris.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => ref.invalidate(myFavoritesProvider), child: const Text('Réessayer')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              'Aucun favori pour l\'instant',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Appuie sur le cœur d\'une annonce pour la retrouver ici.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesShimmerGrid extends StatelessWidget {
  const _FavoritesShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.surfaceMuted,
        highlightColor: AppColors.background,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
      ),
    );
  }
}
