import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/category_model.dart';
import 'package:image_picker/image_picker.dart';

class StepLocationReview extends StatelessWidget {
  const StepLocationReview({
    super.key,
    required this.cityController,
    required this.communeController,
    required this.category,
    required this.title,
    required this.images,
    required this.isFree,
    required this.price,
  });

  final TextEditingController cityController;
  final TextEditingController communeController;
  final CategoryModel? category;
  final String title;
  final List<XFile> images;
  final bool isFree;
  final String price;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Où se trouve l\'article ?', style: textTheme.headlineLarge),
          const SizedBox(height: 20),

          TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Ville', hintText: 'Ex: Abidjan')),
          const SizedBox(height: 8),
          TextField(controller: communeController, decoration: const InputDecoration(labelText: 'Commune / Quartier', hintText: 'Ex: Cocody')),

          const SizedBox(height: 28),
          Text('Récapitulatif', style: textTheme.headlineMedium),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: images.isNotEmpty
                      ? Image.file(File(images.first.path), width: 64, height: 64, fit: BoxFit.cover)
                      : Container(width: 64, height: 64, color: AppColors.surfaceMuted, child: const Icon(Icons.image_outlined, color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.isEmpty ? 'Sans titre' : title, style: textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        isFree ? 'Gratuit' : (price.isEmpty ? 'Prix non renseigné' : '$price FCFA'),
                        style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(category?.name ?? 'Catégorie non choisie', style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFBF1D8), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre annonce sera examinée avant publication (quelques minutes en général).',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
