// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/core/widgets/buttons.dart';

class GoalSpeedScreen extends StatefulWidget {
  const GoalSpeedScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<GoalSpeedScreen> createState() => _GoalSpeedScreenState();
}

class _GoalSpeedScreenState extends State<GoalSpeedScreen> {
  double _selectedSpeed = 0.0;
  String _speedLabel = 'Recommended';

  @override
  void initState() {
    super.initState();
    _selectedSpeed =
        MeasurementHelper.standardizeWeight(0.7, widget.userData['isMetric']);
  }

  void _updateSpeedLabel(double value) {
    if (value <=
        MeasurementHelper.standardizeWeight(
            0.23, widget.userData['isMetric'])) {
      _speedLabel = 'Slow and Steady';
    } else if (value <=
        MeasurementHelper.standardizeWeight(
            0.91, widget.userData['isMetric'])) {
      _speedLabel = 'Recommended';
    } else {
      _speedLabel = 'You may develop loose skin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'How fast do you want\nto reach your goal?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 64),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Progress per week',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_selectedSpeed.toStringAsFixed(1)} ${MeasurementHelper.getWeightLabel(widget.userData['isMetric'])}',
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSpeedIcon(Icons.directions_walk, Colors.grey[400]!),
                  _buildSpeedIcon(
                      Icons.directions_run,
                      MeasurementHelper.standardizeWeight(
                                      0.23, widget.userData['isMetric']) <=
                                  _selectedSpeed &&
                              _selectedSpeed <=
                                  MeasurementHelper.standardizeWeight(
                                      0.91, widget.userData['isMetric'])
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]!),
                  _buildSpeedIcon(
                      Icons.sports_score,
                      MeasurementHelper.standardizeWeight(
                                  0.91, widget.userData['isMetric']) <=
                              _selectedSpeed
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]!),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: Colors.grey[200],
                  thumbColor: Colors.white,
                  overlayColor: Colors.black.withOpacity(0.1),
                  valueIndicatorColor: Colors.black,
                  trackHeight: 8.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12.0,
                    elevation: 4.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24.0,
                  ),
                ),
                child: Slider(
                  value: _selectedSpeed,
                  min: MeasurementHelper.convertWeight(
                      0.01, widget.userData['isMetric']),
                  max: MeasurementHelper.convertWeight(
                      1.3, widget.userData['isMetric']),
                  divisions: 28,
                  onChanged: (value) {
                    setState(() {
                      _selectedSpeed = value;
                      _updateSpeedLabel(value);
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MeasurementHelper.formatWeight(
                        0.01, widget.userData['isMetric'],
                        decimalPlaces: 1),
                    style: AppTypography.bodyMedium,
                  ),
                  Text(
                    MeasurementHelper.formatWeight(
                        1.3, widget.userData['isMetric'],
                        decimalPlaces: 1),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    _speedLabel,
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/attainable',
                  arguments: {
                    'weeklyGoal': _selectedSpeed,
                    ...widget.userData,
                  },
                ),
                text: 'Next',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }
}
