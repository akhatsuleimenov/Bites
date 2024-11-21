// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/core/widgets/buttons.dart';

class AddLogMenuScreen extends StatelessWidget {
  const AddLogMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Log'),
        leading: const CustomBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuOption(
              context,
              icon: Icons.camera_alt_outlined,
              title: 'Scan Food',
              subtitle: 'Take a photo of your meal',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/food-logging'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context,
              icon: Icons.edit_outlined,
              title: 'Manual Entry',
              subtitle: 'Log food manually',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/manual-entry'),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context,
              icon: Icons.fitness_center_outlined,
              title: 'Log Workout',
              subtitle: 'Track your exercise',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context,
              icon: Icons.qr_code_scanner_outlined,
              title: 'Scan Barcode',
              subtitle: 'Scan product barcode',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineMedium,
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
