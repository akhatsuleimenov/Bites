// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/widgets/cards.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const CustomBackButton(),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsCard(
                  title: 'Edit Profile',
                  icon: Icons.person,
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/edit-profile'),
                ),
                const SizedBox(height: 12),
                SettingsCard(
                  title: 'Update Goals',
                  icon: Icons.track_changes,
                  onTap: () => Navigator.pushNamed(context, '/settings/goals'),
                ),
                const SizedBox(height: 12),
                SettingsCard(
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/support'),
                ),
                const SizedBox(height: 12),
                SettingsCard(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/privacy'),
                ),
                const SizedBox(height: 12),
                SettingsCard(
                  title: 'Delete Account',
                  icon: Icons.delete_forever,
                  onTap: () =>
                      Navigator.pushNamed(context, '/settings/delete-account'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SettingsCard(
              title: 'Sign Out',
              icon: Icons.logout,
              onTap: () async {
                await authService.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              textColor: Colors.red.shade900,
              iconColor: Colors.red.shade900,
              isTrailingIcon: false,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
