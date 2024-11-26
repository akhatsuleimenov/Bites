// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/core/widgets/buttons.dart';

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
  late double _currentWeight;
  late double _selectedWeight;
  late bool _isMetric;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.userData['isMetric'];
    _currentWeight = widget.userData['weight'];
    _selectedWeight = _currentWeight;
    _scrollController =
        FixedExtentScrollController(initialItem: _currentWeight.toInt());
  }

  String get _weightDifferenceText {
    final difference = _selectedWeight - _currentWeight;
    if (difference.abs() < 0.5) return 'Maintain Weight';
    return difference > 0 ? 'Gain Weight' : 'Lose Weight';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 32),

              Text(
                'What\'s your target weight?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Current weight: ${MeasurementHelper.formatWeight(_currentWeight, _isMetric)}',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Weight difference indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _weightDifferenceText,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Weight picker
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedWeight = index.toDouble();
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: MeasurementHelper.childCountWeightPicker(
                              _isMetric),
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                MeasurementHelper.formatWeight(
                                    index.toDouble(), _isMetric),
                                style: AppTypography.headlineMedium.copyWith(
                                  color: _scrollController.selectedItem == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  final updatedUserData = {
                    ...widget.userData,
                    'targetWeight': _selectedWeight,
                  };

                  Navigator.pushNamed(
                    context,
                    '/onboarding/birth',
                    arguments: updatedUserData,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
