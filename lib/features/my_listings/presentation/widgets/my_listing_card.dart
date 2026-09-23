import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';

class MyListingCard extends StatelessWidget {
  const MyListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onMarkAsSold,
    required this.onDelete,
  });

  final ListingModel listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onMarkAsSold;
  final VoidCallback onDelete;

  ({String label, Color color, Color background}) get _statusInfo {
    switch (listing.status) {
      case 'published':
        return (label: 'Publiée', color: AppColors.accentGreen, background: const Color(0xFFE9F3EC));
      case 'pending_review':
        return (label: 'En attente', color: AppColors.accentGold, background: const Color(0xFFFBF1D8));
      case 'rejected':
        return (label: 'Refusée', color: AppColors.error, background: AppColors.error.withValues(alpha: 0.08));
      case 'sold':
        return (label: 'Vendue', color: AppColors.textSecondary, background: AppColors.surfaceMuted);
      case 'archived':
        return (label: 'Archivée', color: AppColors.textMuted, background: AppColors.surfaceMuted);
      default:
        return (label: 'Brouillon', color: AppColors.textMuted, background: AppColors.surfaceMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _statusInfo;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: listing.coverImageUrl.isEmpty
                    ? Container(color: AppColors.surfaceMuted, child: const Icon(Icons.image_outlined, color: AppColors.textMuted))
                    : CachedNetworkImage(imageUrl: listing.coverImageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: status.background, borderRadius: BorderRadius.circular(20)),
                    child: Text(status.label, style: TextStyle(color: status.color, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),
                  Text(listing.title, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    listing.formattedPrice,
                    style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  if (listing.status == 'rejected' && listing.rejectionReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      listing.rejectionReason!,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'sold') onMarkAsSold();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (listing.status != 'sold')
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                if (listing.status == 'published')
                  const PopupMenuItem(value: 'sold', child: Text('Marquer comme vendue')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
