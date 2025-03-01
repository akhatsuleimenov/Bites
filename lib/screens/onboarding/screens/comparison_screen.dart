// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/utils/measurement_utils.dart';

class ComparisonScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ComparisonScreen({super.key, required this.userData});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract relevant data from userData
    final bool isMetric = widget.userData['isMetric'] as bool;
    final double targetWeight = widget.userData['targetWeight'] as double;
    final double currentWeight = widget.userData['weight'] as double;
    final double weeklyGoal = widget.userData['weeklyGoal'] as double;

    // Calculate estimated completion date based on weekly goal
    final double weightDifference = (targetWeight - currentWeight).abs();
    final double weeksNeeded = weightDifference / weeklyGoal;
    final DateTime estimatedDate =
        DateTime.now().add(Duration(days: (weeksNeeded * 7).round()));

    // Format the date
    final String formattedDate = _formatDate(estimatedDate);

    // Get weight unit
    final String weightUnit = MeasurementHelper.getWeightLabel(isMetric);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "You're All Set to Reach\nYour Goals!",
                      style: TypographyStyles.h2(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your journey to a healthier you starts now!",
                      style: TypographyStyles.body(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Goal Overview",
                      style: TypographyStyles.h3(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGoalOverview(
                      targetWeight: targetWeight,
                      estimatedDate: formattedDate,
                      weeklyGoal: weeklyGoal,
                      weightUnit: weightUnit,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildWeightTimeline(
                currentWeight: currentWeight,
                targetWeight: targetWeight,
                startDate: DateTime.now(),
                endDate: formattedDate,
                weightUnit: weightUnit,
                progressAnimation: _progressAnimation,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PrimaryButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/onboarding/custom-plan',
                    arguments: widget.userData,
                  ),
                  textColor: AppColors.textPrimary,
                  text: 'Start My Journey',
                  // icon: Icons.arrow_forward,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOverview({
    required double targetWeight,
    required String estimatedDate,
    required double weeklyGoal,
    required String weightUnit,
  }) {
    print(targetWeight);
    print(widget.userData['weight']);
    return Column(
      children: [
        _buildGoalItem(
          icon: Icons.track_changes,
          title: 'Target weight',
          value: '${targetWeight.toStringAsFixed(0)} $weightUnit',
        ),
        const SizedBox(height: 8),
        _buildGoalItem(
          icon: Icons.calendar_today,
          title: 'Estimated timeframe',
          value: estimatedDate,
        ),
        const SizedBox(height: 8),
        _buildGoalItem(
          icon: Icons.trending_down,
          title: 'Weekly target',
          value:
              '${targetWeight > widget.userData['weight'] ? 'Gain' : 'Lose'} ${weeklyGoal.toStringAsFixed(1)} $weightUnit per week',
        ),
      ],
    );
  }

  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grayBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyStyles.body(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TypographyStyles.bodyBold(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTimeline({
    required double currentWeight,
    required double targetWeight,
    required DateTime startDate,
    required String endDate,
    required String weightUnit,
    required Animation<double> progressAnimation,
  }) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grayBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${currentWeight.toStringAsFixed(0)} $weightUnit',
                      style: TypographyStyles.bodyBold(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${targetWeight.toStringAsFixed(0)} $weightUnit',
                      style: TypographyStyles.bodyBold(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: screenWidth,
              height: 100,
              child: AnimatedBuilder(
                animation: progressAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Horizontal dotted line - full screen width
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: screenWidth,
                          height: 3,
                          child: CustomPaint(
                            size: Size(screenWidth, 3),
                            painter: DashedLinePainter(
                              color: AppColors.primary25,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),

                      // Progress line (animated)
                      Positioned(
                        top: 12,
                        left: 48,
                        child: Container(
                          width: (screenWidth - 124) * progressAnimation.value,
                          height: 3,
                          color: AppColors.primary,
                        ),
                      ),

                      // Start circle
                      Positioned(
                        left: 48,
                        top: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),

                      // End circle - changes color when animation completes
                      Positioned(
                        right: 74,
                        top: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: progressAnimation.value == 1.0
                                ? AppColors.primary
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: progressAnimation.value == 1.0
                                  ? Colors.black
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Vertical dotted line from start circle
                      Positioned(
                        left: 56,
                        top: 20,
                        child: CustomPaint(
                          size: const Size(1, 30),
                          painter: VerticalDashedLinePainter(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      ),

                      // Vertical dotted line from end circle
                      Positioned(
                        right: 81,
                        top: 20,
                        child: CustomPaint(
                          size: const Size(1, 30),
                          painter: VerticalDashedLinePainter(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),

                      // Start date
                      Positioned(
                        left: 24,
                        bottom: 20,
                        child: Text(
                          _formatShortDate(startDate),
                          style: TypographyStyles.subtitle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // End date
                      Positioned(
                        right: 48,
                        bottom: 20,
                        child: Text(
                          "${endDate}",
                          style: TypographyStyles.subtitle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
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
    return "Jun 1, ${date.year}";
  }

  String _formatShortDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "Feb 9, ${date.year}";
  }
}

class VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  VerticalDashedLinePainter({
    this.color = Colors.grey,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashHeight = 3;
    const double dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
