import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/presentation/utils/category_icons.dart';

class StepCategory extends StatelessWidget {
  const StepCategory({super.key, required this.categories, required this.selected, required this.onSelected});

  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel> onSelected;

  Future<void> _handleTap(BuildContext context, CategoryModel category) async {
    if (category.children.isEmpty) {
      onSelected(category);
      return;
    }

    final chosen = await showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _SubcategorySheet(parent: category),
    );

    if (chosen != null) onSelected(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dans quelle catégorie ?', style: textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text('Choisissez la catégorie qui correspond le mieux à votre article.', style: textTheme.bodyMedium),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selected?.id == category.id ||
                  (selected != null && category.children.any((c) => c.id == selected!.id));

              return InkWell(
                onTap: () => _handleTap(context, category),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconForCategory(category.icon), color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (selected != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFE9F3EC), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Catégorie choisie : ${selected!.name}', style: textTheme.bodyMedium)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubcategorySheet extends StatelessWidget {
  const _SubcategorySheet({required this.parent});

  final CategoryModel parent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(parent.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ...parent.children.map((child) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(child.name),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => Navigator.of(context).pop(child),
                )),
          ],
        ),
      ),
    );
  }
}
