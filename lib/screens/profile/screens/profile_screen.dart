// Flutter imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    final firebaseService = FirebaseService();

    if (userId == null) {
      return const SizedBox.shrink();
    }
    print('ProfileScreen userId: $userId');
    print('ProfileScreen firebaseService: ${firebaseService.toString()}');
    print('ProfileScreen authService: ${authService.toString()}');

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: firebaseService.getUserDataStream(userId),
          builder: (context, snapshot) {
            print('ProfileScreen stream builder called ${snapshot.toString()}');
            if (snapshot.connectionState == ConnectionState.none) {
              print('ProfileScreen stream connection state is none');
              return const SizedBox.shrink();
            }

            if (!snapshot.hasData) {
              print('ProfileScreen stream has no data');
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.isEmpty) {
              print('ProfileScreen stream data is empty');
              return const SizedBox.shrink();
            }

            if (snapshot.hasError) {
              print('ProfileScreen stream error: ${snapshot.error}');
              if (snapshot.error.toString().contains('permission-denied')) {
                return const SizedBox.shrink();
              }
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final userData = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: AppTypography.headlineLarge,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                _buildProfileHeader(userData),
                const SizedBox(height: 32),

                // Stats Cards
                _buildStatsSection(userData),
                const SizedBox(height: 32),

                // Goals Section
                _buildSection(
                  title: 'Current Goals',
                  child: _buildGoalsCard(userData),
                ),
                const SizedBox(height: 24),

                // Activity Section
                _buildSection(
                  title: 'Activity & Experience',
                  child: _buildActivityCard(userData),
                ),
                const SizedBox(height: 24),

                // Body Metrics Section
                _buildSection(
                  title: 'Body Metrics',
                  child: _buildBodyMetricsCard(userData),
                ),
                const SizedBox(height: 24),

                // Preferences Section
                _buildSection(
                  title: 'Preferences',
                  child: _buildPreferencesCard(userData),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          child: Text(
            userData['name'] != null && userData['name'].isNotEmpty
                ? userData['name'][0].toUpperCase()
                : 'U',
            style: AppTypography.headlineLarge,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userData['name'] != null && userData['name'].isNotEmpty
              ? userData['name']
              : 'User',
          style: AppTypography.headlineMedium,
        ),
        Text(
          '${userData['age']} years • ${userData['gender']?[0].toUpperCase()}${userData['gender']?.substring(1)}',
          style: AppTypography.bodyLarge.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> userData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Calories',
            '${userData['dailyCalories']?.round() ?? 0}',
            'kcal',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'BMR',
            '${userData['bmr']?.round() ?? 0}',
            'kcal',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'TDEE',
            '${userData['tdee']?.round() ?? 0}',
            'kcal',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall,
          ),
          Text(
            unit,
            style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineMedium),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildGoalsCard(Map<String, dynamic> userData) {
    String goalText = userData['goal']?.toString().replaceAll('_', ' ') ?? '';
    goalText = goalText
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Current Goal',
              goalText,
              Icons.flag_outlined,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Target Weight',
              MeasurementHelper.formatWeight(
                  userData['targetWeight'], userData['isMetric']),
              Icons.track_changes_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> userData) {
    String frequencyText =
        userData['workoutFrequency']?.toString().replaceAll('_', ' ') ?? '';
    frequencyText = frequencyText
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Workout Frequency',
              frequencyText,
              Icons.fitness_center_outlined,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Activity Multiplier',
              'x${userData['activityMultiplier']?.toStringAsFixed(2) ?? '1.0'}',
              Icons.speed_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsCard(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Height',
              MeasurementHelper.formatHeight(
                  userData['height'], userData['isMetric']),
              Icons.height_outlined,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Weight',
              MeasurementHelper.formatWeight(
                  userData['weight'], userData['isMetric']),
              Icons.monitor_weight_outlined,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Birth Date',
              DateFormat('MMM d, y')
                  .format((userData['birthDate'] as dynamic).toDate()),
              Icons.cake_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Unit System',
              userData['isMetric'] ? 'Metric' : 'Imperial',
              Icons.straighten_outlined,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Notifications',
              userData['notificationsEnabled'] ? 'Enabled' : 'Disabled',
              Icons.notifications_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              Text(
                value,
                style: AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
