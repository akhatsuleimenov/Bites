import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/profile/controllers/profile_controller.dart';
import 'package:provider/provider.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildSettingsList(context, controller),
      ],
    );
  }

  Widget _buildSettingsList(
      BuildContext context, ProfileController controller) {
    return Column(
      children: [
        _SettingsItem(
          icon: Icons.person,
          title: 'Edit Profile',
          onTap: () => _showEditProfileDialog(context, controller),
        ),
        _SettingsItem(
          icon: Icons.fitness_center,
          title: 'Update Goals',
          onTap: () => Navigator.pushNamed(context, '/goals'),
        ),
        _SettingsItem(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () => Navigator.pushNamed(context, '/notifications'),
        ),
        _SettingsItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () => Navigator.pushNamed(context, '/support'),
        ),
        _SettingsItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () => Navigator.pushNamed(context, '/privacy'),
        ),
        _SettingsItem(
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () => _showSignOutDialog(context, controller),
          textColor: Colors.red,
        ),
      ],
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) async {
    final userData = controller.userData;
    final nameController = TextEditingController(text: userData?['name']);
    final isMetric = userData?['isMetric'] ?? true;
    print(userData?['height'] is int);
    print(userData?['height'] is double);
    // Initialize height and weight based on user data
    int height = userData?['height'] ??
        (isMetric ? 170 : 5); // Default to 170 cm or 5 ft
    int weight = userData?['weight'] ??
        (isMetric ? 70 : 150); // Default to 70 kg or 150 lb

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Height (${isMetric ? 'cm' : 'ft'})',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildHeightPicker(isMetric, height, (newHeight) {
                        height = newHeight;
                      }),
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
                          'Weight (${isMetric ? 'kg' : 'lb'})',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildWeightPicker(isMetric, weight, (newWeight) {
                        weight = newWeight;
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.updateUserData({
                  'name': nameController.text,
                  'height': height,
                  'weight': weight,
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPicker(
      bool isMetric, int currentHeight, ValueChanged<int> onChanged) {
    final maxHeight = isMetric ? 250 : 8; // 250 cm or 8 ft
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (isMetric) {
              return Center(child: Text('$index cm'));
            } else {
              return Center(child: Text('${index} ft'));
            }
          },
          childCount: maxHeight + 1,
        ),
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: currentHeight),
      ),
    );
  }

  Widget _buildWeightPicker(
      bool isMetric, int currentWeight, ValueChanged<int> onChanged) {
    final maxWeight = isMetric ? 200 : 400; // 200 kg or 400 lb
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (isMetric) {
              return Center(child: Text('$index kg'));
            } else {
              return Center(child: Text('${index} lb'));
            }
          },
          childCount: maxWeight + 1,
        ),
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: currentWeight),
      ),
    );
  }

  Future<void> _showSignOutDialog(
    BuildContext context,
    ProfileController controller,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => controller.signOut(context),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
