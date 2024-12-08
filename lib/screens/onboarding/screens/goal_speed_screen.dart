import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class GoalSpeedScreen extends StatefulWidget {
  const GoalSpeedScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<GoalSpeedScreen> createState() => _GoalSpeedScreenState();
}

class _GoalSpeedScreenState extends State<GoalSpeedScreen> {
  double _selectedSpeed = 1.5;
  String _speedLabel = 'Recommended';

  void _updateSpeedLabel(double value) {
    if (value <= 0.5) {
      _speedLabel = 'Slow and Steady';
    } else if (value <= 2.0) {
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
                      '${_selectedSpeed.toStringAsFixed(1)} lbs',
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
                      _selectedSpeed > 0.5 && _selectedSpeed <= 2.0
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]!),
                  _buildSpeedIcon(
                      Icons.sports_score,
                      _selectedSpeed > 2.0
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
                  min: 0.2,
                  max: 3.0,
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
                    '0.2 lbs',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '3.0 lbs',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
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
