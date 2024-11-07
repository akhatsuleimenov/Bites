import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

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
  final DateTime _minDate = DateTime(1900);
  final DateTime _maxDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365 * 20)), // Default to 20 years ago
      firstDate: _minDate,
      lastDate: _maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Select your birth date';
    return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
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
                'When were you born?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your nutrition plan',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // Date Selection Button
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formattedDate,
                        style: AppTypography.bodyLarge.copyWith(
                          color: _selectedDate == null
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              if (_selectedDate != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
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
                        style: AppTypography.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  final updatedUserData = {
                    ...widget.userData,
                    'birthDate': _selectedDate,
                    'age': _age,
                  };
                  Navigator.pushNamed(
                    context,
                    '/onboarding/workouts',
                    arguments: updatedUserData,
                  );
                },
                enabled: _selectedDate != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
