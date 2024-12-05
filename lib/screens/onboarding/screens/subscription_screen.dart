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
  late final SubscriptionController _subscriptionController;

  @override
  void initState() {
    super.initState();
    _subscriptionController = context.read<SubscriptionController>();
    _subscriptionController.addListener(_onSubscriptionUpdate);
  }

  void _onSubscriptionUpdate() {
    if (_subscriptionController.hasActiveSubscription) {
      _handleSuccessfulSubscription();
    }
  }

  Future<void> _handleSuccessfulSubscription() async {
    final authService = context.read<AuthService>();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authService.currentUser!.uid)
        .update({'isSubscribed': true});

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/onboarding/payment-success',
      );
    }
  }

  Future<void> _handleSubscription(String userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _subscriptionController.purchaseSubscription();

      if (success) {
        await _handleSuccessfulSubscription();
      } else {
        setState(() {
          _errorMessage = 'Subscription purchase failed';
        });
      }
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

    final bool isProcessing = _isLoading || subscriptionController.isLoading;

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
    _subscriptionController.removeListener(_onSubscriptionUpdate);
    super.dispose();
  }
}
