// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<String> get foodvisorApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['FOODVISOR_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'FOODVISOR_API_KEY',
    );
  }

  static const foodvisorApiUrl =
      'https://vision.foodvisor.io/api/1.0/en/analysis/';

  static Future<String> get appleApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['APPLE_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'APPLE_API_KEY',
    );
  }

  static Future<String> get superwallApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['SUPERWALL_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'SUPERWALL_API_KEY',
    );
  }
}
