import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({super.key, required this.seller, this.onViewProfileTap});

  final ListingSellerModel seller;
  final VoidCallback? onViewProfileTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surfaceMuted,
            backgroundImage: seller.avatarUrl != null ? CachedNetworkImageProvider(seller.avatarUrl!) : null,
            child: seller.avatarUrl == null
                ? Text(
                    seller.fullName.isNotEmpty ? seller.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(seller.fullName, style: textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                    ),
                    if (seller.isVerifiedSeller) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.accentGreen),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                    const SizedBox(width: 2),
                    Text(
                      seller.ratingAverage > 0 ? seller.ratingAverage.toStringAsFixed(1) : 'Nouveau',
                      style: textTheme.bodySmall,
                    ),
                    if (seller.username != null) ...[
                      const SizedBox(width: 6),
                      Text('· @${seller.username}', style: textTheme.bodySmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onViewProfileTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Profil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
