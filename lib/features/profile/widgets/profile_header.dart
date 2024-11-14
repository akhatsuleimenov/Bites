// Flutter imports:
import 'package:flutter/material.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/profile/controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final userData = controller.userData;

    return BaseCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: Text(
              (userData?['name'] as String?)?.substring(0, 1).toUpperCase() ??
                  'U',
              style: AppTypography.headlineLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData?['name'] ?? 'User',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 8),
          _buildStatsRow(userData ?? {}),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat('Height',
            '${userData['height'] ?? 0} ${userData['isMetric'] ? 'cm' : 'ft'}'),
        _buildStat('Weight',
            '${userData['weight'] ?? 0} ${userData['isMetric'] ? 'kg' : 'lb'}'),
        _buildStat('Goal', _formatGoal(userData['goal'])),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatGoal(String? goal) {
    if (goal == null) return 'N/A';
    return goal
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
