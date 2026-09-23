import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../providers/favorite_overrides_provider.dart';
import '../providers/home_providers.dart';
import '../utils/communes.dart';
import '../widgets/commune_picker_sheet.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hero_search.dart';
import '../widgets/listing_card.dart';
import '../widgets/trok_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  /// null = "Toutes les localités". Un LocationPoint avec `commune` renseigné
  /// = commune précise d'Abidjan ; avec seulement `city` = une autre ville de CI.
  LocationPoint? _selectedLocation;

  ({String? city, String? commune, String? location}) get _locationFilter =>
      (city: _selectedLocation?.city, commune: _selectedLocation?.commune, location: _selectedLocation?.freeText);

  void _handleNavTap(int index) {
    // IMPORTANT: go() REMPLACE l'écran courant, contrairement à push() qui
    // empile -> indispensable pour des onglets de navigation principale, sinon
    // on accumule des instances d'écrans (et parfois liées à un ancien compte
    // après une déconnexion/reconnexion) qui peuvent apparaître furtivement.
    // Seul "Vendre" (index 2) reste en push, car c'est un vrai flux à part.
    switch (index) {
      case 0:
        break; // déjà ici
      case 1:
        context.go('/favorites');
      case 2:
        context.push('/create-listing');
      case 3:
        context.go('/messages');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categoriesAsync = ref.watch(categoriesProvider);
    final listingsAsync = ref.watch(nearbyListingsProvider(_locationFilter));
    final favoriteOverrides = ref.watch(favoriteOverridesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: TrokBottomNav(currentIndex: _navIndex, onTap: _handleNavTap),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(nearbyListingsProvider(_locationFilter));
            await Future.wait([
              ref.read(categoriesProvider.future),
              ref.read(nearbyListingsProvider(_locationFilter).future),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: HomeHeader(
                    locationLabel: _selectedLocation?.label ?? "Côte d'Ivoire",
                    onNotificationTap: () {},
                    onLocationTap: () {},
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: HomeHeroSearch(
                    headlineLocation: _selectedLocation?.label ?? "Côte d'Ivoire",
                    selectedLocationLabel: _selectedLocation?.label,
                    onSearchTap: () => context.push('/search'),
                    onQuartierTap: () async {
                      final chosen = await showLocationPicker(context, current: _selectedLocation);
                      if (!context.mounted || chosen == null) return; // sheet fermé sans choix -> on ne touche à rien
                      setState(() {
                        // Le sentinel "Toutes les localités" a city==null && commune==null
                        _selectedLocation = (chosen.city == null && chosen.commune == null) ? null : chosen;
                      });
                    },
                    onExploreTap: () {},
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: categoriesAsync.when(
                    data: (categories) => HomeCategoriesSection(
                      categories: categories,
                      onSeeAllTap: () {},
                      onCategoryTap: (CategoryModel category) {
                        // TODO: context.push('/category/${category.id}')
                      },
                    ),
                    loading: () => const _CategoriesShimmer(),
                    error: (error, _) => _InlineError(
                      message: 'Impossible de charger les catégories.',
                      onRetry: () => ref.invalidate(categoriesProvider),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Près de chez vous', style: textTheme.headlineMedium),
                          const SizedBox(height: 2),
                          Text(
                            _selectedLocation != null
                                ? 'Annonces à ${_selectedLocation!.label}'
                                : "Annonces récentes en Côte d'Ivoire",
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                        label: const Text('Filtres', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
              listingsAsync.when(
                data: (paginated) {
                  if (paginated.items.isEmpty) {
                    return const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      sliver: SliverToBoxAdapter(
                        child: _EmptyState(message: 'Aucune annonce pour le moment. Reviens bientôt !'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = paginated.items[index];
                          return ListingCard(
                            listing: listing,
                            isFavorited: favoriteOverrides[listing.id] ?? listing.isFavoritedByViewer,
                            onTap: () => context.push('/listing/${listing.id}'),
                            onFavoriteTap: () => ref.read(favoriteOverridesProvider.notifier).toggle(listing),
                          );
                        },
                        childCount: paginated.items.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: _ListingsShimmerGrid(),
                ),
                error: (error, _) => SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  sliver: SliverToBoxAdapter(
                    child: _InlineError(
                      message: 'Impossible de charger les annonces.',
                      onRetry: () => ref.invalidate(nearbyListingsProvider(_locationFilter)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceMuted,
        highlightColor: AppColors.background,
        child: Row(
          children: List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(height: 8),
                  Container(width: 50, height: 10, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingsShimmerGrid extends StatelessWidget {
  const _ListingsShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Shimmer.fromColors(
          baseColor: AppColors.surfaceMuted,
          highlightColor: AppColors.background,
          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
        ),
        childCount: 4,
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error))),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
