// Flutter imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
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
  late bool _isMetric;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.userData['isMetric'] as bool;
    // Set default in proper units
    _selectedSpeed = _isMetric ? 0.4 : 0.9; // 0.4kg or ~0.9lb
    _calculateEstimatedDate();
  }

  String get _weightUnit => MeasurementHelper.getWeightLabel(_isMetric);

  double get _recommendedMin => _isMetric ? 0.1 : 0.22;
  double get _recommendedMax => _isMetric ? 0.6 : 1.32;

  bool get _isRecommendedRate {
    final speedInKg = _selectedSpeed;
    return speedInKg >= 0.1 && speedInKg <= 0.6;
  }

  double get _displaySpeed => _isMetric ? _selectedSpeed : _selectedSpeed * 2.2;

  void _calculateEstimatedDate() {
    // Get current and target weights
    final double currentWeight = widget.userData['weight'] as double;
    final double targetWeight = widget.userData['targetWeight'] as double;
    _weightDifference = (targetWeight - currentWeight).abs();

    // Convert speed to kg for calculations if using imperial
    final double speedInKg = _isMetric ? _selectedSpeed : _selectedSpeed;

    // Prevent division by zero by using a minimum value
    final double speedForCalculation = speedInKg < 0.05 ? 0.05 : speedInKg;

    print(
        'weightDifference: $_weightDifference speedForCalculation: $speedForCalculation');

    // Calculate weeks needed based on selected speed
    final double weeksNeeded = _weightDifference / speedForCalculation;

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
            '${_displaySpeed.toStringAsFixed(1)}',
            style: TypographyStyles.h2(),
          ),
          const SizedBox(width: 8),
          Text(
            _weightUnit,
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

  Widget _buildSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: AppColors.cardBackground,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12.0,
              elevation: 0,
              pressedElevation: 0,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 20.0,
            ),
            tickMarkShape: const RoundSliderTickMarkShape(
              tickMarkRadius: 0,
            ),
            trackShape: CustomTrackShape(
              recommendedMin: _recommendedMin,
              recommendedMax: _recommendedMax,
              isMetric: _isMetric,
            ),
          ),
          child: Slider(
            value: _selectedSpeed,
            min: 0,
            max: 1.0,
            divisions: _isMetric ? 10 : 22,
            onChanged: (value) {
              // Check if crossing the recommended range boundaries
              final bool wasRecommended = _selectedSpeed >= _recommendedMin &&
                  _selectedSpeed <= _recommendedMax;
              final bool isNowRecommended =
                  value >= _recommendedMin && value <= _recommendedMax;

              // Provide different feedback when crossing boundaries
              if (wasRecommended != isNowRecommended) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.lightImpact();
              }

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
              '0 $_weightUnit',
              style: TypographyStyles.body(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_isMetric ? "1.0" : "2.2"} $_weightUnit',
              style: TypographyStyles.body(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationBadge() {
    final bool isRecommended = _isRecommendedRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isRecommended ? AppColors.primary25 : AppColors.errorBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isRecommended ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isRecommended ? AppColors.primary : AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            isRecommended ? 'Recommended rate' : 'Not recommended rate',
            style: TypographyStyles.body(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDate() {
    // Check if speed is effectively zero
    if (_selectedSpeed < 0.05) {
      final bool isMale = widget.userData['gender'] == 'male';
      final String message = isMale
          ? 'Oh, you really don\'t want to achieve your goals?'
          : 'Take your time, there\'s no rush to reach your goal.';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warningBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TypographyStyles.body(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Regular estimated date display for non-zero speeds
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'At this pace, you\'ll reach your goal by ${_formatDate(_estimatedDate)}.',
              style: TypographyStyles.body(
                color: AppColors.textPrimary,
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
            const SizedBox(height: 56),
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
            const SizedBox(height: 8),
            _buildSlider(),
            const SizedBox(height: 16),
            _buildRecommendationBadge(),
          ],
        ),
      ),
      warningWidget: _buildEstimatedDate(),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  final double recommendedMin;
  final double recommendedMax;
  final bool isMetric;

  CustomTrackShape({
    required this.recommendedMin,
    required this.recommendedMax,
    required this.isMetric,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double? additionalActiveTrackHeight,
  }) {
    final Canvas canvas = context.canvas;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Paint border for the entire track
    final Paint borderPaint = Paint()
      ..color = AppColors.inputBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      const Radius.circular(2),
    );
    canvas.drawRRect(trackRRect, borderPaint);

    // Calculate recommended range positions
    final double trackLength = trackRect.width;
    final double recommendedStartX = trackRect.left +
        (trackLength * (recommendedMin / (isMetric ? 1.0 : 2.2)));
    final double recommendedEndX = trackRect.left +
        (trackLength * (recommendedMax / (isMetric ? 1.0 : 2.2)));

    // Paint recommended range in green
    final Paint recommendedPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(
        recommendedStartX,
        trackRect.top,
        recommendedEndX,
        trackRect.bottom,
      ),
      recommendedPaint,
    );

    // Paint thumb border
    final Paint thumbBorderPaint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw thumb border
    canvas.drawCircle(
      thumbCenter,
      12.0,
      thumbBorderPaint,
    );
  }
}
