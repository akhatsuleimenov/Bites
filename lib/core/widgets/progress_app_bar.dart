import 'package:bites/core/constants/app_colors.dart';
// import 'package:bites/core/widgets/buttons.dart';
import 'package:flutter/material.dart';

class ProgressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const ProgressAppBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 72,
        child: AppBar(
          toolbarHeight: 72,
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              // Progress Indicator
              Expanded(
                child: Row(
                  children: List.generate(totalSteps, (index) {
                    bool isActive = index < currentStep;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.inputBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}
