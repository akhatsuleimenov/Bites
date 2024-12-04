import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import '../services/revenue_cat_service.dart';

class SubscriptionController extends ChangeNotifier {
  bool _hasActiveSubscription = false;
  bool _isLoading = false;
  Package? _selectedPackage;
  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isLoading => _isLoading;
  Package? get selectedPackage => _selectedPackage;

  SubscriptionController() {
    _initSubscription();
  }

  Future<void> _initSubscription() async {
    await _checkSubscriptionStatus();
    await _loadOfferings();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      print('checking subscription status');
      final customerInfo = await RevenueCatService.getCustomerInfo();
      _hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
      notifyListeners();
    } catch (e) {
      print('Error checking subscription status: $e');
    }
  }

  Future<void> _loadOfferings() async {
    try {
      print('loading offerings');
      final offerings = await RevenueCatService.getOfferings();
      if (offerings.isNotEmpty) {
        _selectedPackage = offerings.first.availablePackages.first;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading offerings: $e');
    }
  }

  Future<bool> purchaseSubscription() async {
    print('purchasing subscription');
    if (_selectedPackage == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      print('purchasing package: ${_selectedPackage?.storeProduct.title}');
      final customerInfo =
          await RevenueCatService.purchasePackage(_selectedPackage!);
      print('customer info: $customerInfo');
      _hasActiveSubscription =
          customerInfo?.entitlements.active.isNotEmpty ?? false;
      print('has active subscription: $_hasActiveSubscription');
      notifyListeners();
      return _hasActiveSubscription;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
