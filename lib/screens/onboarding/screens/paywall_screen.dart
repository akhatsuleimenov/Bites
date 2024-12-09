// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';

class PaywallScreen extends StatefulWidget {
  final String userId;
  const PaywallScreen({super.key, required this.userId});

  @override
  PaywallScreenState createState() => PaywallScreenState();
}

class PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    print('Init state');
    super.initState();
    // Call paywall on next frame to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePaywall(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Your existing _handlePaywall method here
  void _handlePaywall(BuildContext context) async {
    try {
      print('Presenting paywall');
      final paywallResult = await RevenueCatUI.presentPaywall();
      print('Paywall result: $paywallResult');
      if (paywallResult == PaywallResult.purchased) {
        print('Paywall purchased. $paywallResult');
        FirebaseService().updateUserData(widget.userId, {
          'isSubscribed': true,
        });
        if (context.mounted) {
          Navigator.pushNamed(context, '/onboarding/payment-success');
        }
      } else {
        print('Paywall not purchased. $paywallResult');
      }
    } catch (e) {
      print('Error presenting paywall: $e');
    }
  }
}
