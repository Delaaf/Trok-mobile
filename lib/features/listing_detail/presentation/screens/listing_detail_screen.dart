import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/presentation/providers/favorite_overrides_provider.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../widgets/listing_badges.dart';
import '../widgets/listing_image_carousel.dart';
import '../widgets/seller_card.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(listingDetailProvider(listingId));
    final favoriteOverrides = ref.watch(favoriteOverridesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        data: (listing) => _ListingDetailContent(
          listing: listing,
          isFavorited: favoriteOverrides[listing.id] ?? listing.isFavoritedByViewer,
          onFavoriteTap: () => ref.read(favoriteOverridesProvider.notifier).toggle(listing),
          onBackTap: () => context.pop(),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => _DetailError(onRetry: () => ref.invalidate(listingDetailProvider(listingId))),
      ),
    );
  }
}

class _ListingDetailContent extends StatelessWidget {
  const _ListingDetailContent({
    required this.listing,
    required this.isFavorited,
    required this.onFavoriteTap,
    required this.onBackTap,
  });

  final ListingModel listing;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // laisse la place à la barre flottante
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingImageCarousel(
                images: listing.images,
                isFavorited: isFavorited,
                onBackTap: onBackTap,
                onFavoriteTap: onFavoriteTap,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix + titre
                    Text(
                      listing.formattedPrice,
                      style: textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(listing.title, style: textTheme.headlineLarge),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(listing.commune ?? listing.city ?? '—', style: textTheme.bodySmall),
                        const SizedBox(width: 12),
                        const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text('${listing.viewsCount} vues', style: textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InfoBadge(label: listing.conditionLabel, icon: Icons.verified_outlined, color: AppColors.accentGreen, backgroundColor: const Color(0xFFE9F3EC)),
                        if (listing.isNegotiable)
                          const InfoBadge(label: 'Prix négociable', icon: Icons.handshake_outlined, color: AppColors.primary, backgroundColor: Color(0xFFFBE9DD)),
                        if (listing.acceptsExchange)
                          const InfoBadge(label: 'Échange possible', icon: Icons.swap_horiz_rounded, color: AppColors.accentGold, backgroundColor: Color(0xFFFBF1D8)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (listing.seller != null) ...[
                      Text('Vendeur', style: textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      SellerCard(
                        seller: listing.seller!,
                        onViewProfileTap: () {}, // TODO: context.push('/users/${listing.seller!.id}')
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text('Description', style: textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    Text(
                      listing.description ?? 'Aucune description fournie.',
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
                    ),

                    if (listing.attributes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Caractéristiques', style: textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      AttributesList(attributes: listing.attributes),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Barre d'action flottante
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Material(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onFavoriteTap,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorited ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: naviguer vers la messagerie (module Reverb pas encore construit)
                      // context.push('/messages/new?listingId=${listing.id}')
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Contacter le vendeur'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Impossible de charger cette annonce.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
