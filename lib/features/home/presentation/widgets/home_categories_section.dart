import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../utils/category_icons.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    super.key,
    required this.categories,
    this.onSeeAllTap,
    this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<CategoryModel>? onCategoryTap;

  static const _bgTints = [
    Color(0xFFE9F3EC),
    Color(0xFFFBE9DD),
    Color(0xFFF0EAE3),
    Color(0xFFFBF1D8),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catégories', style: textTheme.headlineMedium),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Text('Tout voir', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              final tint = _bgTints[index % _bgTints.length];

              return InkWell(
                onTap: () => onCategoryTap?.call(category),
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                        child: Icon(iconForCategory(category.icon), color: AppColors.textPrimary, size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
