import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

class WarningMessage extends StatelessWidget {
  const WarningMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.warning,
              size: 24.0,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TypographyStyles.body(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
