import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

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
      _cmController = FixedExtentScrollController(
        initialItem:
            _selectedHeight - MeasurementHelper.offsetHeightPicker(true),
      );
    } else {
      final imperialHeight =
          MeasurementHelper.convertHeight(_selectedHeight, false) as List<int>;
      _feetController = FixedExtentScrollController(
        initialItem:
            imperialHeight[0] - MeasurementHelper.offsetHeightPicker(false),
      );
      _inchesController = FixedExtentScrollController(
        initialItem: imperialHeight[1],
      );
    }
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
          SizedBox(
            height: 200,
            child: _isMetric
                ? _buildMetricHeightPicker()
                : _buildImperialHeightPicker(),
          ),
        ],
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
