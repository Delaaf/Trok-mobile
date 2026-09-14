import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WizardProgressBar extends StatelessWidget {
  const WizardProgressBar({super.key, required this.currentStep, required this.totalSteps, required this.stepLabel});

  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            stepLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
