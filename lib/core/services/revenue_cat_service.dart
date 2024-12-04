import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const _apiKey = 'appl_guTldjSMBOFrsbtNhBfLmQIBMVA';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Purchases.configure(PurchasesConfiguration(_apiKey));
    _initialized = true;
  }

  static Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  static Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      print('Error fetching offerings: $e');
      return [];
    }
  }

  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      print('purchasing package: ${package.storeProduct.title}');
      final purchaseResult = await Purchases.purchasePackage(package);
      print('purchased package: $purchaseResult');
      return purchaseResult;
    } catch (e) {
      print('Error purchasing package: $e');
      rethrow;
    }
  }
}
