// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String foodvisorApiKey = dotenv.env['FOODVISOR_API_KEY'] ?? '';
  static const foodvisorApiUrl =
      'https://vision.foodvisor.io/api/1.0/en/analysis/';
}
