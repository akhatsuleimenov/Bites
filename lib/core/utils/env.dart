// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
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

  static Future<String> get geminiApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'GEMINI_API_KEY',
    );
  }

  static Future<String> get amplitudeApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['AMPLITUDE_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'AMPLITUDE_API_KEY',
    );
  }

  static Future<String> get openaiApiKey async {
    if (bool.fromEnvironment('dart.vm.product') == false) {
      await dotenv.load();
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    }
    // Production
    return const String.fromEnvironment(
      'OPENAI_API_KEY',
    );
  }
}
