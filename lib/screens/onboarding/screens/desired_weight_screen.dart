// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/screens/onboarding/widgets/custom_number_picker.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

class DesiredWeightScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DesiredWeightScreen({
    super.key,
    required this.userData,
  });

  @override
  State<DesiredWeightScreen> createState() => _DesiredWeightScreenState();
}

class _DesiredWeightScreenState extends State<DesiredWeightScreen> {
  late bool _isMetric;
  late double currentWeightKg;
  late double targetWeightKg;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.userData['isMetric'];
    currentWeightKg = widget.userData['weight'];
    targetWeightKg =
        currentWeightKg; // Initialize target weight to current weight
  }

  void _updateTargetWeight(int value) {
    setState(() {
      if (_isMetric) {
        targetWeightKg = value.toDouble();
      } else {
        targetWeightKg = (value * MeasurementHelper.lbToKg).roundToDouble();
      }
    });
  }

  Color _getDifferenceColor() {
    final difference = targetWeightKg - currentWeightKg;
    if (difference.abs() < 0.5) return Colors.blue;
    return difference > 0 ? Colors.orange : Colors.green;
  }

  Widget _buildWarningWidget() {
    final difference = targetWeightKg - currentWeightKg;
    final diffValue = _isMetric
        ? difference.abs().round()
        : (difference.abs() / MeasurementHelper.lbToKg).round();
    final unit = _isMetric ? 'kg' : 'lb';

    String message;
    Color color;
    IconData icon;

    if (difference.abs() < 0.5) {
      message =
          'This target weight suggests you\'ll be aiming to maintain weight.';
      color = Colors.blue;
      icon = Icons.info_outline;
    } else if (difference > 0) {
      message =
          'This target weight suggests you\'ll be aiming to gain ${diffValue} ${unit}.';
      color = Colors.orange;
      icon = Icons.trending_up;
    } else {
      message =
          'This target weight suggests you\'ll be aiming to lose ${diffValue} ${unit}.';
      color = Colors.green;
      icon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _isMetric
        ? targetWeightKg.round()
        : MeasurementHelper.convertWeight(targetWeightKg, false).round();

    return OnboardingLayout(
      currentStep: 5,
      totalSteps: 8,
      title: 'What\'s your target weight?',
      subtitle:
          'Current weight: ${MeasurementHelper.formatWeight(currentWeightKg, _isMetric)}',
      enableContinue: true,
      warningWidget: _buildWarningWidget(),
      onContinue: () {
        Navigator.pushNamed(
          context,
          '/onboarding/birth',
          arguments: {
            ...widget.userData,
            'targetWeight': targetWeightKg,
          },
        );
      },
      child: Column(
        children: [
          // Unit Toggle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _UnitToggleButton(
                    text: 'Metric',
                    isSelected: _isMetric,
                    onTap: () => setState(() => _isMetric = true),
                  ),
                  _UnitToggleButton(
                    text: 'Imperial',
                    isSelected: !_isMetric,
                    onTap: () => setState(() => _isMetric = false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Ruler number picker
          Stack(
            children: [
              // Current weight indicator
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 2,
                    height: 60,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
              RulerNumberPicker(
                minValue:
                    MeasurementHelper.offsetWeightPicker(_isMetric).round(),
                maxValue: _isMetric ? 200 : 440,
                initialValue: currentValue,
                indicatorColor: _getDifferenceColor(),
                indicatorWidth: 2,
                onValueChanged: _updateTargetWeight,
                textStyle: TypographyStyles.h2(
                  color: AppColors.textPrimary,
                ),
                unit: MeasurementHelper.getWeightLabel(_isMetric),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
