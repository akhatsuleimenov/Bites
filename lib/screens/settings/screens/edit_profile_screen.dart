// Flutter imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/models/user_profile_model.dart';
import 'package:bites/core/widgets/buttons.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) => const EditProfileScreenContent(),
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
    return Consumer<AppController>(
      builder: (context, controller, _) {
        // Initialize values from userData only once
        if (_profile.isEmpty()) {
          _profile = controller.userProfile;
          _nameController.text = _profile.name;
          _heightController = FixedExtentScrollController(
              initialItem: MeasurementHelper.convertHeight(
                      _profile.height, _profile.isMetric)
                  .toInt());
          _weightController = FixedExtentScrollController(
              initialItem: MeasurementHelper.convertWeight(
                      _profile.weight, _profile.isMetric)
                  .toInt());
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
                            'Height (${MeasurementHelper.getHeightLabel(_profile.isMetric)})',
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
                                _profile.height = value;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    MeasurementHelper.formatHeight(
                                        index, _profile.isMetric),
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount:
                                  MeasurementHelper.childCountHeightPicker(
                                      _profile.isMetric)[0],
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
                            'Weight (${MeasurementHelper.getWeightLabel(_profile.isMetric)})',
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
                                _profile.weight = value.toDouble();
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    MeasurementHelper.formatWeight(
                                        index.toDouble(), _profile.isMetric),
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount:
                                  MeasurementHelper.childCountWeightPicker(
                                      _profile.isMetric),
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

      await context.read<AppController>().updateProfile(
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
