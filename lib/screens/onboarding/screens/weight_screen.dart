import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/onboarding/widgets/custom_number_picker.dart';
import 'package:flutter/material.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';
import 'package:bites/screens/onboarding/widgets/unit_selector.dart';

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
    final currentValue = _isMetric
        ? weightKg.round()
        : MeasurementHelper.convertWeight(weightKg, false).round();

    return OnboardingLayout(
      currentStep: 4,
      totalSteps: 8,
      title: 'What\'s your current weight?',
      subtitle: 'This helps us track your progress and customize your plan',
      enableContinue: true,
      onContinue: () {
        Navigator.pushNamed(
          context,
          '/onboarding/desired-weight',
          arguments: {
            ...widget.userData,
            'weight': weightKg,
            'isMetric': _isMetric,
          },
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: UnitSelector(
              isMetric: _isMetric,
              onUnitChanged: (value) => setState(() => _isMetric = value),
            ),
          ),
          const SizedBox(height: 56),
          RulerNumberPicker(
            minValue: MeasurementHelper.offsetWeightPicker(_isMetric).round(),
            maxValue: _isMetric ? 200 : 440,
            initialValue: currentValue,
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
