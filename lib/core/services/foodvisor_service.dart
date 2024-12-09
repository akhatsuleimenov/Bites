// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:bites/core/utils/env.dart';

class FoodvisorService {
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final url = Env.foodvisorApiUrl;
      final headers = {"Authorization": "Api-Key ${Env.foodvisorApiKey}"};

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        if (decodedData.containsKey('detail')) {
          throw FoodvisorException(
              'Failed to analyze image: ${decodedData['detail']}');
        } else {
          throw FoodvisorException('Failed to analyze image');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

class FoodvisorException implements Exception {
  final String message;
  FoodvisorException(this.message);
  @override
  String toString() => message;
}
