import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/screens/onboarding/widgets/unit_selector.dart';

class HeightScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HeightScreen({
    super.key,
    required this.userData,
  });

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  bool _isMetric = true;
  late FixedExtentScrollController _cmController;
  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchesController;

  int _selectedHeight = MeasurementHelper.initialItemHeightPicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isMetric) {
      final cmPosition =
          _selectedHeight - MeasurementHelper.offsetHeightPicker(true);
      _cmController = FixedExtentScrollController(
        initialItem: cmPosition,
      );
    } else {
      final imperialHeight =
          MeasurementHelper.convertHeight(_selectedHeight, false) as List<int>;
      final feet = imperialHeight[0];
      final inches = imperialHeight[1];
      final feetPosition = feet - 4;

      _feetController = FixedExtentScrollController(
        initialItem: feetPosition,
      );
      _inchesController = FixedExtentScrollController(
        initialItem: inches,
      );
    }
  }

  void _switchUnit(bool toMetric) {
    if (_isMetric == toMetric) return;

    final currentHeightCm = _selectedHeight;

    setState(() {
      _disposeControllers();
      _isMetric = toMetric;
      _selectedHeight = currentHeightCm;
      _initializeControllers();
    });
  }

  Widget _buildWheelScrollView(
    FixedExtentScrollController controller,
    int childCount,
    Function(int) onSelectedItemChanged,
    int offset,
  ) {
    return Container(
      width: 64,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 32,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: childCount,
          builder: (context, index) {
            final displayValue = index + offset;
            return Center(
              child: Text(
                '$displayValue',
                style: controller.selectedItem == index
                    ? TypographyStyles.h3(color: AppColors.textPrimary)
                    : TypographyStyles.h3(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricHeightPicker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary25,
            border: Border.all(
              color: AppColors.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWheelScrollView(
                    _cmController,
                    MeasurementHelper.childCountHeightPicker(true)[0],
                    (value) {
                      final newHeight =
                          value + MeasurementHelper.offsetHeightPicker(true);
                      if (newHeight >= 100 && newHeight <= 240) {
                        // Validate height range
                        setState(() {
                          _selectedHeight = newHeight;
                        });
                      }
                    },
                    MeasurementHelper.offsetHeightPicker(true),
                  ),
                  Text(
                    'cm',
                    style: TypographyStyles.bodyBold(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImperialHeightPicker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary25,
            border: Border.all(color: AppColors.primary, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ImperialNumberPicker(
                    controller: _feetController,
                    minValue: 4,
                    maxValue: 7,
                    onChanged: (feet) {
                      setState(() {
                        final inches = _inchesController.selectedItem;
                        _selectedHeight = MeasurementHelper.parseImperialHeight(
                            [feet, inches]);
                      });
                    },
                  ),
                  Text('ft',
                      style: TypographyStyles.bodyBold(
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 16),
                  _ImperialNumberPicker(
                    controller: _inchesController,
                    minValue: 0,
                    maxValue: 11,
                    onChanged: (inches) {
                      setState(() {
                        final feet = _feetController.selectedItem + 4;
                        _selectedHeight = MeasurementHelper.parseImperialHeight(
                            [feet, inches]);
                      });
                    },
                  ),
                  Text('in',
                      style: TypographyStyles.bodyBold(
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 3,
      totalSteps: 8,
      title: 'What\'s your height?',
      subtitle:
          'This helps us calculate your BMI and personalize your experience',
      enableContinue: true,
      onContinue: () {
        Navigator.pushNamed(
          context,
          '/onboarding/weight',
          arguments: {
            ...widget.userData,
            'height': _selectedHeight,
            'isMetric': _isMetric,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: UnitSelector(
                isMetric: _isMetric,
                onUnitChanged: _switchUnit,
              ),
            ),
            const SizedBox(height: 56),
            _isMetric
                ? _buildMetricHeightPicker()
                : _buildImperialHeightPicker(),
          ],
        ),
      ),
    );
  }

  void _disposeControllers() {
    if (_isMetric) {
      _cmController.dispose();
    } else {
      _feetController.dispose();
      _inchesController.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}

class _ImperialNumberPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _ImperialNumberPicker({
    required this.controller,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 32,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => onChanged(index + minValue),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue - minValue + 1,
          builder: (context, index) {
            final value = index + minValue;
            return Center(
              child: Text(
                '$value',
                style: controller.selectedItem == index
                    ? TypographyStyles.h3(color: AppColors.textPrimary)
                    : TypographyStyles.h3(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}
