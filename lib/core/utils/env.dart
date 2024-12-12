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
      defaultValue: '', // Flutter will replace this during build
    );
  }

  static const foodvisorApiUrl =
      'https://vision.foodvisor.io/api/1.0/en/analysis/';

  static Future<String> get appleApiKey async {
    print('I AM IN ENV');
    if (bool.fromEnvironment('dart.vm.product') == false) {
      print('I AM IN DEBUG');
      await dotenv.load();
      print('DEBUG: ${dotenv.env['APPLE_API_KEY']}');
      return dotenv.env['APPLE_API_KEY'] ?? '';
    }
    print('I AM IN PRODUCTION');
    // Production
    return const String.fromEnvironment(
      'APPLE_API_KEY',
      defaultValue: '', // Flutter will replace this during build
    );
  }
}
