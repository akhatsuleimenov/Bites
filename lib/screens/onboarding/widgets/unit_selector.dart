import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';

class UnitSelector extends StatelessWidget {
  final bool isMetric;
  final Function(bool) onUnitChanged;

  const UnitSelector({
    super.key,
    required this.isMetric,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Animated background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isMetric ? 2 : 98,
            top: 2,
            child: Container(
              width: 92,
              height: 31,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Buttons row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UnitButton(
                text: 'Metric',
                isSelected: isMetric,
                onTap: () => onUnitChanged(true),
              ),
              _UnitButton(
                text: 'Imperial',
                isSelected: !isMetric,
                onTap: () => onUnitChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 35,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TypographyStyles.bodyMedium(
              color:
                  isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
