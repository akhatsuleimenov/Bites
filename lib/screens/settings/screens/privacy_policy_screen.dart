// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: const CustomBackButton(),
        backgroundColor: AppColors.cardBackground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Privacy Policy',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: November 15, 2024',
            style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Information We Collect',
            content:
                'We collect information that you provide directly to us, including your name, email address, height, weight, and fitness goals. This information is used to personalize your experience and provide accurate nutritional recommendations.',
          ),
          _buildSection(
            title: 'How We Use Your Information',
            content: 'Your information is used to:\n'
                '• Provide personalized meal plans and recommendations\n'
                '• Calculate your daily nutritional needs\n'
                '• Track your progress towards your fitness goals\n'
                '• Improve our services and develop new features',
          ),
          _buildSection(
            title: 'Data Security',
            content:
                'We implement appropriate security measures to protect your personal information. Your data is encrypted during transmission and stored securely on our servers.',
          ),
          _buildSection(
            title: 'Third-Party Services',
            content:
                'We may use third-party services to help us operate our application. These services have access to your information only to perform specific tasks on our behalf.',
          ),
          _buildSection(
            title: 'Your Rights',
            content: 'You have the right to:\n'
                '• Access your personal data\n'
                '• Correct inaccurate data\n'
                '• Request deletion of your data\n'
                '• Export your data\n'
                '• Opt-out of marketing communications',
          ),
          _buildSection(
            title: 'Changes to This Policy',
            content:
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
          ),
          const SizedBox(height: 32),
          Text(
            'Contact Us',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'If you have any questions about this Privacy Policy, please contact us at:\n\n'
            'Email: privacy@bites.com\n'
            'Address: San Francisco, CA, USA',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
