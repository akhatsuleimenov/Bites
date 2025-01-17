// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:google_generative_ai/google_generative_ai.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/utils/env.dart';

class GeminiSerivce {
  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  Future<FoodInfo> analyzeImage(String imagePath) async {
    print('Starting Gemini analysis for image: $imagePath');

    final apiKey = await Env.geminiApiKey;
    print(
        'Retrieved API key from Env: ${apiKey.isEmpty ? 'EMPTY' : 'NOT EMPTY'}');

    if (apiKey.isEmpty) {
      print('❌ GEMINI_API_KEY is empty');
      throw Exception('Gemini API key not found');
    }

    try {
      print('Initializing Gemini model...');
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: Schema(
            SchemaType.object,
            enumValues: [],
            requiredProperties: [
              "mainItem",
              "description",
              "healthScore",
              "ingredients"
            ],
            properties: {
              "mainItem": Schema(
                SchemaType.object,
                enumValues: [],
                requiredProperties: ["title", "grams", "nutritionData"],
                properties: {
                  "title": Schema(
                    SchemaType.string,
                  ),
                  "grams": Schema(
                    SchemaType.number,
                  ),
                  "nutritionData": Schema(
                    SchemaType.object,
                    enumValues: [],
                    requiredProperties: [
                      "calories",
                      "carbs",
                      "protein",
                      "fats"
                    ],
                    properties: {
                      "calories": Schema(
                        SchemaType.number,
                      ),
                      "carbs": Schema(
                        SchemaType.number,
                      ),
                      "protein": Schema(
                        SchemaType.number,
                      ),
                      "fats": Schema(
                        SchemaType.number,
                      ),
                    },
                  ),
                },
              ),
              "description": Schema(
                SchemaType.string,
              ),
              "healthScore": Schema(
                SchemaType.number,
              ),
              "ingredients": Schema(
                SchemaType.array,
                items: Schema(
                  SchemaType.object,
                  enumValues: [],
                  requiredProperties: ["title", "grams", "nutritionData"],
                  properties: {
                    "title": Schema(
                      SchemaType.string,
                    ),
                    "grams": Schema(
                      SchemaType.number,
                    ),
                    "nutritionData": Schema(
                      SchemaType.object,
                      enumValues: [],
                      requiredProperties: [
                        "calories",
                        "carbs",
                        "protein",
                        "fats"
                      ],
                      properties: {
                        "calories": Schema(
                          SchemaType.number,
                        ),
                        "carbs": Schema(
                          SchemaType.number,
                        ),
                        "protein": Schema(
                          SchemaType.number,
                        ),
                        "fats": Schema(
                          SchemaType.number,
                        ),
                      },
                    ),
                  },
                ),
              ),
            },
          ),
        ),
        systemInstruction: Content.system(
            'You are an AI calories calculator, you will be given an image of food, and output what ingredients does it contain and its macros(calories, carbs, protein, fat). For description, generate a simple 1 sentence information about the dish/food iteself without information about the photo or anything else. If the image does not look like food, simply return "Not food" string'),
      );
      print('Model initialized, preparing image data...');
      final prompt = 'Describe how this product might be manufactured.';
      final image = await fileToPart('image/jpeg', imagePath);
      print('Image data prepared, sending to Gemini...');

      final response = await model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);
      print(
          'Received response from Gemini: ${response.text?.substring(0, 50)}...');

      final Map<String, dynamic> jsonResponse = json.decode(response.text!);
      print('Successfully parsed JSON response: $jsonResponse');

      return FoodInfo.fromMap(jsonResponse);
    } catch (e, stackTrace) {
      print('❌ Gemini service error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
