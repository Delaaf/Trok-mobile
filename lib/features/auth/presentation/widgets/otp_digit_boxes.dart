import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OtpDigitBoxes extends StatelessWidget {
  const OtpDigitBoxes({super.key, required this.code, this.length = 4});

  final String code;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (index) {
        final hasDigit = index < code.length;
        final isActive = index == code.length;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == length - 1 ? 0 : 12),
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Text(
              hasDigit ? code[index] : '',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        );
      }),
    );
  }
}
