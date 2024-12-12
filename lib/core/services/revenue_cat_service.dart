// Package imports:
import 'package:bites/core/utils/env.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static String _apiKey = "";
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    _apiKey = await Env.appleApiKey;
    await Purchases.configure(PurchasesConfiguration(_apiKey));
    _initialized = true;
  }
}
