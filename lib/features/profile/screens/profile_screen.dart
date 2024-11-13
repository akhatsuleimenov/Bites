import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/profile/widgets/profile_header.dart';
import 'package:nutrition_ai/features/profile/widgets/settings_section.dart';
import 'package:nutrition_ai/features/profile/controllers/profile_controller.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<ProfileController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.loadUserData,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Profile',
                      style: AppTypography.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    const ProfileHeader(),
                    const SizedBox(height: 24),
                    const SettingsSection(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
