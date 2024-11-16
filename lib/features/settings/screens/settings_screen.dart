import 'package:flutter/material.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const CustomBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsCard(
            title: 'Edit Profile',
            icon: Icons.person,
            onTap: () => Navigator.pushNamed(context, '/settings/edit-profile'),
          ),
          const SizedBox(height: 12),
          SettingsCard(
            title: 'Update Goals',
            icon: Icons.track_changes,
            onTap: () => Navigator.pushNamed(context, '/settings/goals'),
          ),
          // const SizedBox(height: 12),
          // SettingsCard(
          //   title: 'Notifications',
          //   icon: Icons.notifications_outlined,
          //   onTap: () => Navigator.pushNamed(context, '/settings/notifications'),
          // ),
          const SizedBox(height: 12),
          SettingsCard(
            title: 'Help & Support',
            icon: Icons.help_outline,
            onTap: () => Navigator.pushNamed(context, '/settings/support'),
          ),
          const SizedBox(height: 12),
          SettingsCard(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => Navigator.pushNamed(context, '/settings/privacy'),
          ),
        ],
      ),
    );
  }
}
