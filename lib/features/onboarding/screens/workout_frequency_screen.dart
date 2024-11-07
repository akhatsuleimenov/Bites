import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WorkoutFrequencyScreen({
    super.key,
    required this.userData,
  });

  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  String? _selectedFrequency;

  final List<Map<String, dynamic>> _frequencies = [
    {
      'id': 'sedentary',
      'title': 'Sedentary',
      'subtitle': 'Little to no exercise',
      'icon': Icons.weekend,
      'multiplier': 1.2,
    },
    {
      'id': 'light',
      'title': '1-2 times a week',
      'subtitle': 'Light exercise',
      'icon': Icons.directions_walk,
      'multiplier': 1.375,
    },
    {
      'id': 'moderate',
      'title': '3-5 times a week',
      'subtitle': 'Moderate exercise',
      'icon': Icons.directions_run,
      'multiplier': 1.55,
    },
    {
      'id': 'active',
      'title': '6-7 times a week',
      'subtitle': 'Very active',
      'icon': Icons.fitness_center,
      'multiplier': 1.725,
    },
    {
      'id': 'athlete',
      'title': 'Athlete',
      'subtitle': 'Professional/Intense training',
      'icon': Icons.sports_gymnastics,
      'multiplier': 1.9,
    },
  ];

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
                'How often do youwork out?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us calculate your daily calorie needs',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _frequencies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final frequency = _frequencies[index];
                    final isSelected = _selectedFrequency == frequency['id'];

                    return _FrequencyCard(
                      title: frequency['title'],
                      subtitle: frequency['subtitle'],
                      icon: frequency['icon'],
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedFrequency = frequency['id'];
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  final selectedFrequency = _frequencies.firstWhere(
                    (f) => f['id'] == _selectedFrequency,
                  );

                  final updatedUserData = {
                    ...widget.userData,
                    'workoutFrequency': _selectedFrequency,
                    'activityMultiplier': selectedFrequency['multiplier'],
                  };

                  Navigator.pushNamed(
                    context,
                    '/onboarding/experience',
                    arguments: updatedUserData,
                  );
                },
                enabled: _selectedFrequency != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: isSelected ? Colors.white : Colors.transparent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
