// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:bites/core/utils/env.dart';

class FoodvisorService {
  static const int maxFileSize = 1024 * 1024; // 1MB

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      String processedImage_path = imageFile.path;

      if (await imageFile.length() > maxFileSize) {
        final dir = await getTemporaryDirectory();
        final targetPath =
            path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

        final result = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: 85,
          format: CompressFormat.jpeg,
        );

        if (result != null) {
          processedImage_path = result.path;
        }
      }

      final url = Env.foodvisorApiUrl;
      final headers = {"Authorization": "Api-Key ${await Env.foodvisorApiKey}"};

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers)
        ..files.add(
            await http.MultipartFile.fromPath('image', processedImage_path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('SUCCESS: FoodvisorService responseData: $responseData');
        return json.decode(responseData);
      } else {
        final responseData = await response.stream.bytesToString();
        print('ERROR: FoodvisorService responseData: $responseData');
        final decodedData = json.decode(responseData);
        if (decodedData.containsKey('detail')) {
          print('FoodvisorException: ${decodedData}');
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
