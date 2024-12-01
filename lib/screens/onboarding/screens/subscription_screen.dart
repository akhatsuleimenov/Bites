import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bites/core/controllers/subscription_controller.dart';
import 'package:bites/core/widgets/buttons.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final subscriptionController = context.read<SubscriptionController>();
    // Listen for subscription status changes
    subscriptionController.addListener(_onSubscriptionUpdate);
  }

  void _onSubscriptionUpdate() {
    final subscriptionController = context.read<SubscriptionController>();
    if (subscriptionController.hasActiveSubscription) {
      _handleSuccessfulSubscription();
    }
  }

  Future<void> _handleSuccessfulSubscription() async {
    final authService = context.read<AuthService>();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authService.currentUser!.uid)
        .update({'subscriptionActive': true});

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    }
  }

  Future<void> _handleSubscription(String userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('purchase');
      final subscriptionController = context.read<SubscriptionController>();
      print('purchase2');
      await subscriptionController.purchaseYearlySubscription();
      // Don't navigate here - wait for purchase stream update
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process subscription: $e';
      });
      print(_errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser!.uid;
    final subscriptionController = context.watch<SubscriptionController>();

    final bool isProcessing =
        _isLoading || subscriptionController.isPurchasePending;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Unlock Full Access',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),
              if (isProcessing)
                const CircularProgressIndicator()
              else
                PrimaryButton(
                  text: 'Subscribe Now',
                  onPressed: () => _handleSubscription(userId),
                ),
              const SizedBox(height: 16),
              Text(
                'Free 3-day trial, cancel anytime',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    final subscriptionController = context.read<SubscriptionController>();
    subscriptionController.removeListener(_onSubscriptionUpdate);
    super.dispose();
  }
}
