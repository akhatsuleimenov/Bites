import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

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
    _isMetric = widget.userData['isMetric'] as bool;
    _currentWeight = widget.userData['weight'] as double;

    // Convert current weight to imperial if needed
    if (!_isMetric) {
      _currentWeight = _currentWeight * 2.20462; // Convert kg to lbs
    }
    _selectedWeight = _currentWeight;

    // Initialize scroll controller based on the unit system
    final minWeight = _isMetric ? 30.0 : 66.0;
    final initialItem = (_currentWeight - minWeight).round();
    _scrollController = FixedExtentScrollController(
      initialItem: initialItem,
    );
  }

  String get _weightDifferenceText {
    final difference = _selectedWeight - _currentWeight;
    if (difference.abs() < 0.5) return 'Maintain Weight';
    return difference > 0 ? 'Gain Weight' : 'Lose Weight';
  }

  String _formatWeight(int index) {
    final minWeight = _isMetric ? 30.0 : 66.0;
    final weight = index + minWeight;
    return '${weight.toStringAsFixed(1)} ${_isMetric ? 'kg' : 'lbs'}';
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
                'Current weight: ${_currentWeight.toStringAsFixed(1)} ${_isMetric ? 'kg' : 'lbs'}',
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
                            final minWeight = _isMetric ? 30.0 : 66.0;
                            _selectedWeight = index + minWeight;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount:
                              _isMetric ? 221 : 485, // 30-250kg or 66-550lbs
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                _formatWeight(index),
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
                  double targetWeightKg = _selectedWeight;
                  double weightDifferenceKg;

                  if (!_isMetric) {
                    // Convert target weight from lbs to kg for storage
                    targetWeightKg = _selectedWeight / 2.20462;
                    // Convert current weight from lbs to kg for difference calculation
                    final currentWeightKg = _currentWeight / 2.20462;
                    weightDifferenceKg = targetWeightKg - currentWeightKg;
                  } else {
                    weightDifferenceKg = _selectedWeight - _currentWeight;
                  }

                  final updatedUserData = {
                    ...widget.userData,
                    'targetWeight': targetWeightKg, // Always store in kg
                    'weightDifference':
                        weightDifferenceKg, // Always store in kg
                    'displayUnit': _isMetric
                        ? 'metric'
                        : 'imperial', // Store user's preference
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
