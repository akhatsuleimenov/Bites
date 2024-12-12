// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class PaywallScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PaywallScreen({super.key, required this.userData});

  @override
  PaywallScreenState createState() => PaywallScreenState();
}

class PaywallScreenState extends State<PaywallScreen> {
  bool _showRetry = false;

  @override
  void initState() {
    print('Init state');
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePaywall(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _showRetry
            ? Stack(
                children: [
                  // Centered text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Payment Unsuccessful',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Would you like to try again?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: PrimaryButton(
                        onPressed: () {
                          setState(() => _showRetry = false);
                          _handlePaywall(context);
                        },
                        text: 'Try Again',
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  void _handlePaywall(BuildContext context) async {
    try {
      print('Presenting paywall');
      final paywallResult = await RevenueCatUI.presentPaywall();
      print('Paywall result: $paywallResult');
      if (paywallResult == PaywallResult.purchased) {
        print('Paywall purchased. $paywallResult');
        FirebaseService().updateUserData(widget.userData['userId'], {
          'isSubscribed': true,
        });
        if (context.mounted) {
          Navigator.pushNamed(context, '/onboarding/payment-success');
        }
      } else if (paywallResult == PaywallResult.cancelled) {
        print('Paywall cancelled. $paywallResult');
        if (mounted) {
          setState(() => _showRetry = true);
        }
      }
    } catch (e) {
      print('Error presenting paywall: $e');
      if (mounted) {
        setState(() => _showRetry = true);
      }
    }
  }
}
