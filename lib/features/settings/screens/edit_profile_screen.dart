import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/settings/controllers/settings_controller.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsController>(
      create: (_) => SettingsController()..loadUserData(),
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
  late TextEditingController _nameController;
  late int _height;
  late int _weight;
  late bool _isMetric;
  late FixedExtentScrollController _heightController;
  late FixedExtentScrollController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _height = 170;
    _weight = 70;
    _isMetric = true;
    _initializeControllers();
  }

  void _initializeControllers() {
    _heightController = FixedExtentScrollController(
      initialItem: _height - (_isMetric ? 100 : 4),
    );
    _weightController = FixedExtentScrollController(
      initialItem: _weight - (_isMetric ? 30 : 66),
    );
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
        if (_nameController.text.isEmpty) {
          _nameController.text = userData['name'] ?? '';
          _isMetric = userData['isMetric'] ?? true;
          _height = userData['height'] ?? (_isMetric ? 170 : 5);
          _weight = userData['weight'] ?? (_isMetric ? 70 : 150);

          // Update controllers with initial values
          _heightController.jumpToItem(_height - (_isMetric ? 100 : 4));
          _weightController.jumpToItem(_weight - (_isMetric ? 30 : 66));
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
                            'Height (${_isMetric ? 'cm' : 'ft'})',
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
                                _height = value + (_isMetric ? 100 : 4);
                                print(
                                    "Height updated to: $_height"); // Debug print
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final value =
                                    _isMetric ? index + 100 : index + 4;
                                return Center(
                                  child: Text(
                                    '$value ${_isMetric ? 'cm' : 'ft'}',
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount: _isMetric ? 141 : 5,
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
                            'Weight (${_isMetric ? 'kg' : 'lb'})',
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
                                _weight = value + (_isMetric ? 30 : 66);
                                print(
                                    "Weight updated to: $_weight"); // Debug print
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final value =
                                    _isMetric ? index + 30 : index + 66;
                                return Center(
                                  child: Text(
                                    '$value ${_isMetric ? 'kg' : 'lb'}',
                                    style: AppTypography.bodyLarge,
                                  ),
                                );
                              },
                              childCount: _isMetric ? 171 : 335,
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
                value: _isMetric,
                onChanged: (value) => setState(() => _isMetric = value),
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
      print("Saving height: $_height, weight: $_weight"); // Debug print
      await context.read<SettingsController>().updateProfile({
        'name': _nameController.text,
        'height': _height,
        'weight': _weight,
        'isMetric': _isMetric,
      });

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
}
