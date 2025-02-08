import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';

class AnalyzingIndicator extends StatelessWidget {
  final bool isAnalyzing;
  final bool analysisComplete;
  final Animation<double> progressAnimation;

  const AnalyzingIndicator({
    super.key,
    required this.isAnalyzing,
    required this.analysisComplete,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAnalyzing) return const SizedBox.shrink();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: (MediaQuery.of(context).size.width - 220) / 2,
      child: Container(
        width: 220,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: progressAnimation,
              builder: (context, child) {
                return Container(
                  width: 220 * progressAnimation.value,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                );
              },
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!analysisComplete)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.textPrimary,
                      size: 16,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    analysisComplete
                        ? 'Analysis complete'
                        : 'Scanning image...',
                    style: TypographyStyles.bodyMedium(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
