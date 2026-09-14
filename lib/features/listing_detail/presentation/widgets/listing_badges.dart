import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge({super.key, required this.label, required this.icon, this.color = AppColors.textSecondary, this.backgroundColor = AppColors.surfaceMuted});

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class AttributesList extends StatelessWidget {
  const AttributesList({super.key, required this.attributes});

  final Map<String, dynamic> attributes;

  static String _prettifyKey(String key) {
    final withSpaces = key.replaceAll('_', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final entries = attributes.entries.toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_prettifyKey(entry.key), style: textTheme.bodyMedium),
                Text('${entry.value}', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
