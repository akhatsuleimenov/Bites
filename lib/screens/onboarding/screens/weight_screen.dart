import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/onboarding/widgets/custom_number_picker.dart';
import 'package:flutter/material.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

class WeightScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WeightScreen({
    super.key,
    required this.userData,
  });

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  bool _isMetric = true;
  late double weightKg;

  @override
  void initState() {
    super.initState();
    weightKg = MeasurementHelper.initialItemWeightPicker();
  }

  void _updateWeight(int value) {
    setState(() {
      if (_isMetric) {
        weightKg = value.toDouble();
      } else {
        weightKg = (value * MeasurementHelper.lbToKg).roundToDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 4,
      totalSteps: 8,
      title: 'What\'s your current weight?',
      subtitle: 'This helps us track your progress and customize your plan',
      enableContinue: true,
      onContinue: () {
        Navigator.pushNamed(
          context,
          '/onboarding/workouts',
          arguments: {
            ...widget.userData,
            'weight': weightKg,
            'isMetric': _isMetric,
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
          RulerNumberPicker(
            minValue: MeasurementHelper.offsetWeightPicker(_isMetric).round(),
            maxValue: _isMetric ? 200 : 440,
            initialValue: _isMetric
                ? weightKg.round()
                : MeasurementHelper.convertWeight(weightKg, false).round(),
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWidth: 2,
            onValueChanged: _updateWeight,
            textStyle: TypographyStyles.h2(
              color: AppColors.textPrimary,
            ),
            unit: MeasurementHelper.getWeightLabel(_isMetric),
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
