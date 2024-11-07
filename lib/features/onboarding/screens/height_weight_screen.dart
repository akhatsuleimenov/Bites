import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class HeightWeightScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HeightWeightScreen({
    super.key,
    required this.userData,
  });

  @override
  State<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  bool _isMetric = true;

  // Height controllers
  late FixedExtentScrollController _cmController;
  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchesController;

  // Weight controller
  late FixedExtentScrollController _weightController;

  // Selected values
  double _selectedHeight = 170; // Default height in cm
  double _selectedWeight = 70; // Default weight in kg

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize height controllers
    _cmController = FixedExtentScrollController(
      initialItem: 170 - 100, // Default 170cm
    );
    _feetController = FixedExtentScrollController(
      initialItem: 5, // Default 5ft
    );
    _inchesController = FixedExtentScrollController(
      initialItem: 7, // Default 7in
    );

    // Initialize weight controller
    _weightController = FixedExtentScrollController(
      initialItem: (_isMetric ? 70 : 154) -
          (_isMetric ? 30 : 66), // Default 70kg or 154lbs
    );
  }

  void _updateHeight() {
    if (_isMetric) {
      _selectedHeight = _cmController.selectedItem + 100.0;
    } else {
      final feet = _feetController.selectedItem + 4;
      final inches = _inchesController.selectedItem;
      _selectedHeight = (feet * 30.48) + (inches * 2.54); // Convert to cm
    }
    setState(() {});
  }

  void _updateWeight() {
    if (_isMetric) {
      _selectedWeight = _weightController.selectedItem + 30.0;
    } else {
      _selectedWeight =
          (_weightController.selectedItem + 66) * 0.453592; // Convert lbs to kg
    }
    setState(() {});
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
                'What\'s your height\nand weight?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your experience',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

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
                        onTap: () {
                          setState(() {
                            _isMetric = true;
                            _disposeControllers();
                            _initializeControllers();
                          });
                        },
                      ),
                      _UnitToggleButton(
                        text: 'Imperial',
                        isSelected: !_isMetric,
                        onTap: () {
                          setState(() {
                            _isMetric = false;
                            _disposeControllers();
                            _initializeControllers();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Height and Weight Pickers side by side
              Row(
                children: [
                  // Height Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Height',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _isMetric
                              ? _buildMetricHeightPicker()
                              : _buildImperialHeightPicker(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Weight Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Weight',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  controller: _weightController,
                                  itemExtent: 40,
                                  perspective: 0.005,
                                  diameterRatio: 1.2,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (_) => _updateWeight(),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: _isMetric
                                        ? 221
                                        : 485, // 30-250kg or 66-550lbs
                                    builder: (context, index) {
                                      final value = _isMetric
                                          ? (index + 30).toString()
                                          : (index + 66).toString();
                                      return Center(
                                        child: Text(
                                          '$value ${_isMetric ? 'kg' : 'lbs'}',
                                          style:
                                              AppTypography.bodyLarge.copyWith(
                                            color: _weightController
                                                        .selectedItem ==
                                                    index
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  final updatedUserData = {
                    ...widget.userData,
                    'height': _selectedHeight,
                    'weight': _selectedWeight,
                    'isMetric': _isMetric,
                  };

                  Navigator.pushNamed(
                    context,
                    '/onboarding/desired-weight',
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

  Widget _buildMetricHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: ListWheelScrollView.useDelegate(
            controller: _cmController,
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (_) => _updateHeight(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 141, // 100-241cm
              builder: (context, index) {
                return Center(
                  child: Text(
                    '${index + 100} cm',
                    style: AppTypography.bodyLarge.copyWith(
                      color: _cmController.selectedItem == index
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
    );
  }

  Widget _buildImperialHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        // Feet picker
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _feetController,
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (_) => _updateHeight(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 4, // 4-7 feet
              builder: (context, index) {
                return Center(
                  child: Text(
                    '${index + 4}\'',
                    style: AppTypography.bodyLarge.copyWith(
                      color: _feetController.selectedItem == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Inches picker
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _inchesController,
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (_) => _updateHeight(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 12, // 0-11 inches
              builder: (context, index) {
                return Center(
                  child: Text(
                    '$index"',
                    style: AppTypography.bodyLarge.copyWith(
                      color: _inchesController.selectedItem == index
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
    );
  }

  void _disposeControllers() {
    _cmController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _weightController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
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
