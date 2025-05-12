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
        model: 'gemini-2.5-flash-preview-04-17',
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
              "healthScore",
              "confidence",
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
              "healthScore": Schema(
                SchemaType.number,
              ),
              "confidence": Schema(
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
            'You are an AI calories calculator, you will be given an image of food, and output what ingredients does it contain and its macros(calories, carbs, protein, fat). If the image does not look like food, simply return "Not food" string'),
      );
      print('Model initialized, preparing image data...');
      final prompt = '''Step 1: List all visible food items in the image.
                      Step 2: For each item, estimate the portion size in grams.
                      Step 3: Match each item to a standard food category (e.g., USDA).
                      Step 4: Provide calories, carbs, protein, and fat for each item.
                      Step 5: Estimate your confidence in the output from 0-100%.
                      If this image does not look like food, respond with the string: "Not food".''';
      final image = await fileToPart('image/jpeg', imagePath);
      print('Image data prepared, sending to Gemini...');

      final content = Content.multi([TextPart(prompt), image]);

      final tokenCount = await model.countTokens([content]);
      print('Total tokens: ${tokenCount.totalTokens}');

      final response = await model.generateContent([content]);
      print(
          'Received response from Gemini: ${response.text?.substring(0, 50)}...');

      if (response.usageMetadata case final usage?) {
        print('Prompt tokens: ${usage.promptTokenCount}');
        print('Response tokens: ${usage.candidatesTokenCount}');
        print('Total tokens: ${usage.totalTokenCount}');
      }

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
