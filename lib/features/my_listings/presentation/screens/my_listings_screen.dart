import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/data/repositories/listing_repository.dart';
import '../providers/my_listings_providers.dart';
import '../widgets/my_listing_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ListingModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer cette annonce ?'),
        content: Text('« ${listing.title} » sera définitivement supprimée. Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(listingRepositoryProvider).deleteListing(listing.id);
      ref.invalidate(myListingsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _markAsSold(BuildContext context, WidgetRef ref, ListingModel listing) async {
    try {
      await ref.read(listingRepositoryProvider).markAsSold(listing.id);
      ref.invalidate(myListingsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  Text('Mes annonces', style: textTheme.displayMedium),
                ],
              ),
            ),
            Expanded(
              child: listingsAsync.when(
                data: (paginated) {
                  if (paginated.items.isEmpty) return const _EmptyMyListings();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(myListingsProvider);
                      await ref.read(myListingsProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: paginated.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final listing = paginated.items[index];
                        return MyListingCard(
                          listing: listing,
                          onTap: () => context.push('/listing/${listing.id}'),
                          onEdit: () async {
                            final updated = await context.push<bool>('/listing/${listing.id}/edit', extra: listing);
                            if (updated == true) ref.invalidate(myListingsProvider);
                          },
                          onMarkAsSold: () => _markAsSold(context, ref, listing),
                          onDelete: () => _confirmDelete(context, ref, listing),
                        );
                      },
                    ),
                  );
                },
                loading: () => const _MyListingsShimmer(),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Impossible de charger tes annonces.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => ref.invalidate(myListingsProvider), child: const Text('Réessayer')),
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

class _EmptyMyListings extends StatelessWidget {
  const _EmptyMyListings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text('Aucune annonce', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Publie ta première annonce depuis le bouton "+" en bas.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyListingsShimmer extends StatelessWidget {
  const _MyListingsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 92,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
