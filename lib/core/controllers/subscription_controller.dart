import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SubscriptionController extends ChangeNotifier {
  static const String _yearlySubscriptionId = 'com.bites.test';
  bool _hasActiveSubscription = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isPurchasePending = false;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isPurchasePending => _isPurchasePending;

  SubscriptionController() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Error: $error'),
    );

    _cleanPendingPurchases();
  }

  Future<void> _cleanPendingPurchases() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    print('cleaning pending purchases');
    final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
        InAppPurchase.instance
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    print('showing price consent');
    await iosPlatformAddition.showPriceConsentIfNeeded();
    print('showing redemption sheet');
    // Use presentCodeRedemptionSheet to handle any pending transactions
    try {
      print('presenting redemption sheet');
      await iosPlatformAddition.presentCodeRedemptionSheet();
    } catch (e) {
      print('Error presenting redemption sheet: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isPurchasePending = true;
        notifyListeners();
      } else {
        _isPurchasePending = false;
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('Purchase error: ${purchaseDetails.error}');
          // Complete the purchase even on error to clear stuck transactions
          if (purchaseDetails.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyPurchase(purchaseDetails);
          if (purchaseDetails.pendingCompletePurchase) {
            InAppPurchase.instance.completePurchase(purchaseDetails);
          }
        }
        notifyListeners();
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Here you would typically verify the purchase with your backend
    // For now, we'll assume it's valid
    print('verified purchase');
    print('purchaseDetails: $purchaseDetails');
    _hasActiveSubscription = true;
    notifyListeners();
  }

  Future<void> purchaseYearlySubscription() async {
    _cleanPendingPurchases();
    print('cleaned pending purchases');
    if (_isPurchasePending) {
      throw Exception('A purchase is already in progress');
    }

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      throw Exception('Store is not available');
    }

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({_yearlySubscriptionId});

    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Product not found');
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);

    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
