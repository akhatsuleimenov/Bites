// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: const CustomBackButton(),
        backgroundColor: AppColors.cardBackground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How can we help you?',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 24),

          // FAQ Section
          _buildSection(
            title: 'Frequently Asked Questions',
            children: [
              _buildExpandableFAQ(
                'How are my calories calculated?',
                'We use the Mifflin-St Jeor equation along with your activity level to calculate your daily calorie needs. This is then adjusted based on your goals.',
              ),
              _buildExpandableFAQ(
                'Can I change my goals later?',
                'Yes! You can update your goals, weight, and activity level at any time in the Settings section.',
              ),
              _buildExpandableFAQ(
                'How accurate is the calorie tracking?',
                'Our database contains verified nutritional information. However, portion sizes and preparation methods can affect the exact calorie content.',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Contact Section
          Text(
            'Contact Us',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@bites.com',
            onTap: () => _launchEmail('support@bites.com'),
          ),
          // const SizedBox(height: 12),
          // _buildContactCard(
          //   icon: Icons.chat_bubble_outline,
          //   title: 'Live Chat',
          //   subtitle: 'Available 24/7',
          //   onTap: () => _launchChat(),
          // ),

          const SizedBox(height: 32),

          // Social Media Section
          Text(
            'Follow Us',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                onTap: () => _launchUrl('https://facebook.com/bites'),
              ),
              _buildSocialButton(
                icon: Icons.telegram,
                onTap: () => _launchUrl('https://t.me/bites'),
              ),
              _buildSocialButton(
                icon: Icons.discord,
                onTap: () => _launchUrl('https://discord.gg/bites'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineLarge),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildExpandableFAQ(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 32),
      onPressed: onTap,
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // void _launchChat() {}
}
