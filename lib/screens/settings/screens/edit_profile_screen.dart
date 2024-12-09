// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/models/user_profile_model.dart';
import 'package:bites/core/utils/measurement_utils.dart';
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

  // Height controller
  late FixedExtentScrollController _cmController;

  // Weight controller
  late FixedExtentScrollController _kgController;

  late FixedExtentScrollController _feetController;
  late FixedExtentScrollController _inchesController;
  late FixedExtentScrollController _lbController;

  // Add this flag
  bool _isNameInitialized = false;

  @override
  void initState() {
    super.initState();
    _profile = UserProfile();
    _nameController = TextEditingController();
    _initializeControllers();

    // Load app data here instead of in build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().loadAppData();
    });
  }

  void _initializeControllers() {
    _cmController = FixedExtentScrollController(
      initialItem: _profile.height - MeasurementHelper.offsetHeightPicker(true),
    );
    _kgController = FixedExtentScrollController(
      initialItem:
          (_profile.weight - MeasurementHelper.offsetWeightPicker(true))
              .toInt(),
    );

    final imperialHeight =
        MeasurementHelper.convertHeight(_profile.height, false) as List<int>;
    final imperialWeight =
        MeasurementHelper.convertWeight(_profile.weight, false);

    _feetController = FixedExtentScrollController(
      initialItem:
          imperialHeight[0] - MeasurementHelper.offsetHeightPicker(false),
    );
    _inchesController =
        FixedExtentScrollController(initialItem: imperialHeight[1]);
    _lbController = FixedExtentScrollController(
      initialItem:
          (imperialWeight - MeasurementHelper.offsetWeightPicker(false))
              .toInt(),
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    _nameController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _cmController.dispose();
    _kgController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _lbController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        // Update profile data whenever it changes
        _profile = controller.userProfile;

        // Only set the name once when the profile is loaded
        if (!_isNameInitialized && _profile.name.isNotEmpty) {
          _nameController.text = _profile.name;
          _isNameInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: const CustomBackButton(),
            backgroundColor: AppColors.cardBackground,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textPrimary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Height Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Height',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _profile.isMetric
                              ? _buildMetricHeightPicker()
                              : _buildImperialHeightPicker(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Weight Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Weight',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _profile.isMetric
                              ? _buildMetricWeightPicker()
                              : _buildImperialWeightPicker(),
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
                onChanged: (value) {
                  setState(() {
                    _disposeControllers();

                    _profile.isMetric = value;
                    _initializeControllers();
                  });
                },
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
          'isMetric': _profile.isMetric,
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

  Widget _buildMetricHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: _buildWheelScrollView(
            _cmController,
            MeasurementHelper.childCountHeightPicker(true)[0],
            (value) {
              setState(() {
                _profile.height =
                    value + MeasurementHelper.offsetHeightPicker(true);
              });
            },
            MeasurementHelper.offsetHeightPicker(true),
            'cm',
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildImperialHeightPicker() {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: _buildWheelScrollView(
                  _feetController,
                  MeasurementHelper.childCountHeightPicker(false)[0],
                  (value) {
                    setState(() {
                      final feet =
                          value + MeasurementHelper.offsetHeightPicker(false);
                      final inches = _inchesController.selectedItem;
                      _profile.height =
                          MeasurementHelper.parseImperialHeight([feet, inches]);
                    });
                  },
                  MeasurementHelper.offsetHeightPicker(false),
                  'ft',
                ),
              ),
              Expanded(
                child: _buildWheelScrollView(
                  _inchesController,
                  MeasurementHelper.childCountHeightPicker(false)[1],
                  (value) {
                    setState(() {
                      final feet = _feetController.selectedItem +
                          MeasurementHelper.offsetHeightPicker(false);
                      _profile.height =
                          MeasurementHelper.parseImperialHeight([feet, value]);
                    });
                  },
                  0,
                  'in',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildMetricWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _kgController,
            MeasurementHelper.childCountWeightPicker(true),
            (value) {
              setState(() {
                _profile.weight =
                    value + MeasurementHelper.offsetWeightPicker(true);
              });
            },
            MeasurementHelper.offsetWeightPicker(true).toInt(),
            'kg',
          ),
        ),
      ],
    );
  }

  Widget _buildImperialWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _lbController,
            MeasurementHelper.childCountWeightPicker(false),
            (value) {
              setState(() {
                final lbs = value + MeasurementHelper.offsetWeightPicker(false);
                _profile.weight = lbs * MeasurementHelper.lbToKg;
              });
            },
            MeasurementHelper.offsetWeightPicker(false).toInt(),
            'lb',
          ),
        ),
      ],
    );
  }

  Widget _buildWheelScrollView(
    FixedExtentScrollController controller,
    int childCount,
    Function(int) onSelectedItemChanged,
    int offset,
    String unit,
  ) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: childCount,
        builder: (context, index) {
          return Center(
            child: Text(
              '${index + offset} $unit',
              style: AppTypography.bodyLarge.copyWith(
                color: controller.selectedItem == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
