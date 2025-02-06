// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

class GoalSpeedScreen extends StatefulWidget {
  const GoalSpeedScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<GoalSpeedScreen> createState() => _GoalSpeedScreenState();
}

class _GoalSpeedScreenState extends State<GoalSpeedScreen> {
  double _selectedSpeed = 0.0;
  late DateTime _estimatedDate;
  late double _weightDifference;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = 0.4; // Default to recommended rate
    _calculateEstimatedDate();
  }

  void _calculateEstimatedDate() {
    // Get current and target weights
    final double currentWeight = widget.userData['weight'] as double;
    final double targetWeight = widget.userData['targetWeight'] as double;
    _weightDifference = (targetWeight - currentWeight).abs();

    // Calculate weeks needed
    final double weeksNeeded = _weightDifference / _selectedSpeed;

    // Calculate estimated completion date
    _estimatedDate =
        DateTime.now().add(Duration(days: (weeksNeeded * 7).round()));
  }

  Widget _buildWeightDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedSpeed.toStringAsFixed(1)}',
            style: TypographyStyles.h2(),
          ),
          const SizedBox(width: 8),
          Text(
            'Kg',
            style: TypographyStyles.h3(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedIndicators() {
    final List<IconData> speedIcons = [
      Icons.directions_walk,
      Icons.directions_run,
      Icons.sports_score,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (index) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.grayBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            speedIcons[index],
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF9F0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF4CD964),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Recommended rate',
            style: TypographyStyles.bodyMedium(
              color: const Color(0xFF4CD964),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDate() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary25,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'At this pace, you\'ll reach your goal by ${_formatDate(_estimatedDate)}.',
              style: TypographyStyles.bodyMedium(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 8,
      totalSteps: 8,
      title: 'How fast do you want\nto reach your goal?',
      subtitle:
          'Your desired pace helps us balance progress with safety and sustainability in your plan.',
      enableContinue: true,
      onContinue: () => Navigator.pushNamed(
        context,
        '/onboarding/notifications',
        arguments: {
          'weeklyGoal': _selectedSpeed,
          ...widget.userData,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _buildWeightDisplay(),
            const SizedBox(height: 8),
            Text(
              'Progress per week',
              style: TypographyStyles.body(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildSpeedIndicators(),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.grayBackground,
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withOpacity(0.1),
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10.0,
                  elevation: 2.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 20.0,
                ),
              ),
              child: Slider(
                value: _selectedSpeed,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _selectedSpeed = value;
                    _calculateEstimatedDate();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 kg',
                  style: TypographyStyles.body(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '1 kg',
                  style: TypographyStyles.body(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildRecommendationBadge(),
            const SizedBox(height: 16),
            _buildEstimatedDate(),
          ],
        ),
      ),
    );
  }
}
