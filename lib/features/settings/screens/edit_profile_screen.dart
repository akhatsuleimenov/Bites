// Flutter imports:
import 'package:bites/core/services/auth_service.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/features/settings/controllers/settings_controller.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/models/user_profile_model.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsController>(
      create: (context) => SettingsController(
        Provider.of<AuthService>(context, listen: false),
      )..loadUserData(),
      child: const EditProfileScreenContent(),
    );
  }
}

class EditProfileScreenContent extends StatefulWidget {
  const EditProfileScreenContent({super.key});

  @override
  State<EditProfileScreenContent> createState() =>
      _EditProfileScreenContentState();
}

class _EditProfileScreenContentState extends State<EditProfileScreenContent> {
  late UserProfile _profile;
  late TextEditingController _nameController;
  late FixedExtentScrollController _heightController;
  late FixedExtentScrollController _weightController;

  @override
  void initState() {
    super.initState();
    _profile = UserProfile();
    _nameController = TextEditingController();
    _heightController = FixedExtentScrollController(initialItem: 0);
    _weightController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        final userData = controller.userData;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Initialize values from userData only once
        if (_profile.isEmpty()) {
          _profile = UserProfile.fromMap(userData);
          _nameController.text = _profile.name;
          final heightIndex = _profile.height - (_profile.isMetric ? 100 : 4);
          final weightIndex =
              (_profile.weight - (_profile.isMetric ? 30 : 66)).toInt();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _heightController.jumpToItem(heightIndex);
            _weightController.jumpToItem(weightIndex);
            print('heightController: ${_heightController.initialItem}');
            print('weightController: ${_weightController.initialItem}');
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: const CustomBackButton(),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Height (${_profile.isMetric ? 'cm' : 'ft'})',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                _profile.height =
                                    value + (_profile.isMetric ? 100 : 4);
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final value =
                                    _profile.isMetric ? index + 100 : index + 4;
                                return Center(
                                  child: Text(
                                    '$value ${_profile.isMetric ? 'cm' : 'ft'}',
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount: _profile.isMetric ? 141 : 5,
                            ),
                            controller: _heightController,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.005,
                            diameterRatio: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Weight (${_profile.isMetric ? 'kg' : 'lb'})',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                _profile.weight =
                                    value + (_profile.isMetric ? 30 : 66);
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final value =
                                    _profile.isMetric ? index + 30 : index + 66;
                                return Center(
                                  child: Text(
                                    '$value ${_profile.isMetric ? 'kg' : 'lb'}',
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount: _profile.isMetric ? 171 : 335,
                            ),
                            controller: _weightController,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.005,
                            diameterRatio: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title:
                    Text('Use Metric System', style: AppTypography.bodyLarge),
                value: _profile.isMetric,
                onChanged: (value) => setState(() => _profile.isMetric = value),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Changes',
                onPressed: _saveChanges,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    try {
      final bmr = _calculateBMR();
      final tdee = bmr * _profile.activityMultiplier;
      final dailyCalories = (tdee + _profile.calorieAdjustment).round();

      await context.read<SettingsController>().updateProfile(
        {
          'name': _nameController.text,
          'height': _profile.height,
          'weight': _profile.weight,
          'bmr': bmr,
          'tdee': tdee,
          'dailyCalories': dailyCalories,
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  double _calculateBMR() {
    double bmr =
        (10 * _profile.weight) + (6.25 * _profile.height) - (5 * _profile.age);
    bmr += _profile.gender == 'male' ? 5 : -161;
    return bmr;
  }
}
