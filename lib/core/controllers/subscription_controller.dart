// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionController extends ChangeNotifier {
  bool _hasActiveSubscription = false;
  bool get hasActiveSubscription => _hasActiveSubscription;

  SubscriptionController() {
    _initSubscription();
    // Listen to subscription changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      print('customerInfo: $customerInfo');
      _hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
      notifyListeners();

      // Update Firebase when subscription status changes
      final purchaserInfo = await Purchases.getCustomerInfo();
      print('purchaserInfo: $purchaserInfo');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(purchaserInfo.originalAppUserId)
          .update({'isSubscribed': _hasActiveSubscription});
    });
  }

  Future<void> _initSubscription() async {
    try {
      print('initSubscription');
      final customerInfo = await Purchases.getCustomerInfo();
      print('customerInfo: $customerInfo');
      _hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
      notifyListeners();
    } catch (e) {
      print('Error checking subscription status: $e');
    }
  }
}
