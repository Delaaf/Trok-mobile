import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(value, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
