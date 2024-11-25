// Flutter imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

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

  // Weight controller
  late FixedExtentScrollController _kgController;

  // Selected values
  int _selectedHeight = MeasurementHelper.initialItemHeightPicker();
  double _selectedWeight = MeasurementHelper.initialItemWeightPicker();

  // Add imperial controllers
  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchesController;
  late FixedExtentScrollController _lbController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isMetric) {
      _cmController = FixedExtentScrollController(
        initialItem:
            _selectedHeight - MeasurementHelper.offsetHeightPicker(true),
      );
      _kgController = FixedExtentScrollController(
        initialItem:
            (_selectedWeight - MeasurementHelper.offsetWeightPicker(true))
                .toInt(),
      );
    } else {
      final imperialHeight =
          MeasurementHelper.convertHeight(_selectedHeight, false) as List<int>;
      final imperialWeight =
          MeasurementHelper.convertWeight(_selectedWeight, false);

      _feetController = FixedExtentScrollController(
          initialItem:
              imperialHeight[0] - MeasurementHelper.offsetHeightPicker(false));
      _inchesController =
          FixedExtentScrollController(initialItem: imperialHeight[1]);
      _lbController = FixedExtentScrollController(
        initialItem:
            (imperialWeight - MeasurementHelper.offsetWeightPicker(false))
                .toInt(),
      );
    }
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
                            _disposeControllers();
                            _isMetric = true;
                            _initializeControllers();
                          });
                        },
                      ),
                      _UnitToggleButton(
                        text: 'Imperial',
                        isSelected: !_isMetric,
                        onTap: () {
                          setState(() {
                            _disposeControllers();
                            _isMetric = false;
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
                          child: _isMetric
                              ? _buildMetricWeightPicker()
                              : _buildImperialWeightPicker(),
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
                    'weight': double.parse(_selectedWeight.toStringAsFixed(2)),
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

  Widget _buildMetricWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _kgController,
            MeasurementHelper.childCountWeightPicker(_isMetric),
            (value) {
              setState(() {
                _selectedWeight =
                    value + MeasurementHelper.offsetWeightPicker(true);
              });
            },
            MeasurementHelper.offsetWeightPicker(true).toInt(),
            'kg',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: _buildWheelScrollView(
            _cmController,
            MeasurementHelper.childCountHeightPicker(true)[0],
            (value) {
              setState(() {
                _selectedHeight =
                    value + MeasurementHelper.offsetHeightPicker(true);
              });
            },
            MeasurementHelper.offsetHeightPicker(true),
            'cm',
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildWheelScrollView(
    FixedExtentScrollController controller,
    int childCount,
    Function(int) onSelectedItemChanged,
    int offset,
    String unit,
  ) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: childCount,
        builder: (context, index) {
          return Center(
            child: Text(
              '${index + offset} $unit',
              style: AppTypography.bodyLarge.copyWith(
                color: controller.selectedItem == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImperialHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: _buildWheelScrollView(
                  _feetController,
                  MeasurementHelper.childCountHeightPicker(false)[0],
                  (value) {
                    setState(() {
                      final feet =
                          value + MeasurementHelper.offsetHeightPicker(false);
                      final inches = _inchesController.selectedItem;
                      _selectedHeight =
                          MeasurementHelper.parseImperialHeight([feet, inches]);
                    });
                  },
                  MeasurementHelper.offsetHeightPicker(false),
                  'ft',
                ),
              ),
              Expanded(
                child: _buildWheelScrollView(
                  _inchesController,
                  MeasurementHelper.childCountHeightPicker(false)[1],
                  (value) {
                    setState(() {
                      final feet = _feetController.selectedItem +
                          MeasurementHelper.offsetHeightPicker(false);
                      _selectedHeight =
                          MeasurementHelper.parseImperialHeight([feet, value]);
                    });
                  },
                  0,
                  'in',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildImperialWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _lbController,
            MeasurementHelper.childCountWeightPicker(false),
            (value) {
              setState(() {
                final lbs = value + MeasurementHelper.offsetWeightPicker(false);
                _selectedWeight = lbs * MeasurementHelper.lbToKg;
              });
            },
            MeasurementHelper.offsetWeightPicker(false).toInt(),
            'lb',
          ),
        ),
      ],
    );
  }

  void _disposeControllers() {
    if (_isMetric) {
      _cmController.dispose();
      _kgController.dispose();
    } else {
      _feetController.dispose();
      _inchesController.dispose();
      _lbController.dispose();
    }
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
