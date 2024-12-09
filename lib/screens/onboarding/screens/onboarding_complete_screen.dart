// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const OnboardingCompleteScreen({
    super.key,
    required this.userData,
  });

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  final List<bool> _completedSteps = List.generate(4, (_) => false);
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {
          _progress = _progressController.value;
          _updateSteps();
        });
      });

    _startAnimation();
  }

  void _updateSteps() {
    if (_progress >= 0.25) _completedSteps[0] = true;
    if (_progress >= 0.50) _completedSteps[1] = true;
    if (_progress >= 0.75) _completedSteps[2] = true;
    if (_progress >= 0.90) _completedSteps[3] = true;
  }

  Future<void> _startAnimation() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser!.uid;
    await Future.delayed(const Duration(milliseconds: 500));
    await _progressController.forward();
    await _saveUserData(userId, authService.currentUser!.displayName!,
        authService.currentUser!.email!);
    if (mounted) {
      Navigator.pushNamed(context, '/onboarding/comparison', arguments: {
        ...widget.userData,
        'userId': userId,
      });
    }
  }

  Future<void> _saveUserData(String userId, String name, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        ...widget.userData,
        'name': name,
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildProgressItem(String title, bool completed,
      {bool showDivider = true}) {
    return Column(
      children: [
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? Colors.green : Colors.grey[300],
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                completed ? Icons.check : Icons.hourglass_empty,
                color: completed ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: completed ? Colors.green : Colors.grey[600],
                  fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        if (showDivider) const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Creating a Plan for You',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 250),
                builder: (context, double value, _) => Column(
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: AppTypography.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildProgressItem(
                  'Analyzing your lifestyle', _completedSteps[0]),
              _buildProgressItem(
                  'Counting your ideal calorie target', _completedSteps[1]),
              _buildProgressItem('Counting your macros', _completedSteps[2]),
              _buildProgressItem('Finalizing the plan', _completedSteps[3],
                  showDivider: false),
            ],
          ),
        ),
      ),
    );
  }
}
