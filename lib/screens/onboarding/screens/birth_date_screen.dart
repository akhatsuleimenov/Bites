// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Project imports:

class BirthDateScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const BirthDateScreen({
    super.key,
    required this.userData,
  });

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? _selectedDate;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  final int _startYear = 1920;
  final int _currentYear = DateTime.now().year - 2;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2000;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    setState(() {
      _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    });
  }

  void _initializeControllers() {
    _yearController = FixedExtentScrollController(
      initialItem: 2000 - _startYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: 0,
    );
    _dayController = FixedExtentScrollController(
      initialItem: 0,
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateSelectedDate() {
    setState(() {
      _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    });
  }

  Widget _buildScrollWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required Function(int) onChanged,
    double? width,
  }) {
    return Container(
      width: width ?? 64,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 24,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (value) {
          HapticFeedback.lightImpact();
          onChanged(value);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                labelBuilder(index),
                style: controller.selectedItem == index
                    ? TypographyStyles.bodyBold(
                        color: AppColors.textPrimary,
                      )
                    : TypographyStyles.body(
                        color: AppColors.textSecondary,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  int? get _age {
    if (_selectedDate == null) return null;
    final today = DateTime.now();
    int age = today.year - _selectedDate!.year;
    if (today.month < _selectedDate!.month ||
        (today.month == _selectedDate!.month &&
            today.day < _selectedDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 2,
      totalSteps: 8,
      title: 'When were you born?',
      subtitle:
          'Your age plays a key role in determining your metabolism and daily calorie requirements.',
      enableContinue: _selectedDate != null,
      onContinue: () {
        Navigator.pushNamed(
          context,
          '/onboarding/height',
          arguments: {
            ...widget.userData,
            'birthDate': _selectedDate,
            'age': _age,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 56,
        ),
        child: Column(
          children: [
            // Date Scroll Wheels
            Stack(
              alignment: Alignment.center,
              children: [
                // Green highlight container
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary25,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Existing scroll wheels
                SizedBox(
                  height: 130,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day Scroll
                      _buildScrollWheel(
                        controller: _dayController,
                        width: 48,
                        itemCount:
                            _getDaysInMonth(_selectedYear, _selectedMonth),
                        labelBuilder: (index) => '${index + 1}',
                        onChanged: (value) {
                          _selectedDay = value + 1;
                          _updateSelectedDate();
                        },
                      ),
                      const SizedBox(width: 16),

                      // Month Scroll
                      _buildScrollWheel(
                        controller: _monthController,
                        itemCount: 12,
                        labelBuilder: (index) {
                          final month = DateTime(2000, index + 1);
                          return DateFormat('MMM').format(month);
                        },
                        onChanged: (value) {
                          _selectedMonth = value + 1;
                          // Validate day when month changes
                          final daysInMonth =
                              _getDaysInMonth(_selectedYear, _selectedMonth);
                          if (_selectedDay > daysInMonth) {
                            _selectedDay = daysInMonth;
                            _dayController.jumpToItem(daysInMonth - 1);
                          }
                          _updateSelectedDate();
                        },
                      ),
                      const SizedBox(width: 16),

                      // Year Scroll
                      _buildScrollWheel(
                        controller: _yearController,
                        itemCount: _currentYear - _startYear + 1,
                        labelBuilder: (index) => '${_startYear + index}',
                        onChanged: (value) {
                          _selectedYear = _startYear + value;
                          // Validate day when year changes (for leap years)
                          final daysInMonth =
                              _getDaysInMonth(_selectedYear, _selectedMonth);
                          if (_selectedDay > daysInMonth) {
                            _selectedDay = daysInMonth;
                            _dayController.jumpToItem(daysInMonth - 1);
                          }
                          _updateSelectedDate();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_selectedDate != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grayBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'You are $_age years old',
                      style: TypographyStyles.body(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }
}
