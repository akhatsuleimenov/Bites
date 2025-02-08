// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:openai_dart/openai_dart.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/utils/env.dart';

class OpenAIService {
  Future<FoodInfo> analyzeImage(String imagePath) async {
    print('Starting OpenAI analysis for image: $imagePath');

    final apiKey = await Env.openaiApiKey;
    print(
        'Retrieved API key from Env: ${apiKey.isEmpty ? 'EMPTY' : 'NOT EMPTY'}');

    if (apiKey.isEmpty) {
      print('❌ OPENAI_API_KEY is empty');
      throw Exception('OpenAI API key not found');
    }

    try {
      print('Initializing OpenAI...');

      print('Preparing image data...');
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      print('Sending request to OpenAI...');
      final client = OpenAIClient(apiKey: apiKey);
      final response = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.model(
            ChatCompletionModels.gpt4oMini,
          ),
          messages: [
            ChatCompletionMessage.system(
              content:
                  'You are an AI calories calculator. You will be given an image of food, and you need to output what ingredients it contains and its macros (calories, carbs, protein, fat). If the image does not look like food, simply return the string "Not food".',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.parts(
                [
                  ChatCompletionMessageContentPart.text(
                      text:
                          'Analyze this food image and provide nutritional information.'),
                  ChatCompletionMessageContentPart.image(
                    imageUrl: ChatCompletionMessageImageUrl(
                        url: 'data:image/jpeg;base64,$base64Image'),
                  )
                ],
              ),
            )
          ],
          temperature: 1,
          maxTokens: 10000,
          topP: 1,
          responseFormat: ResponseFormat.jsonSchema(
            jsonSchema: JsonSchemaObject(
              name: 'FoodInfo',
              schema: {
                'type': 'object',
                'required': ['mainItem', 'healthScore', 'ingredients'],
                'properties': {
                  'mainItem': {
                    'type': 'object',
                    'required': ['title', 'grams', 'nutritionData'],
                    'properties': {
                      'grams': {
                        'type': 'number',
                        'description': 'The weight of the main item in grams.'
                      },
                      'title': {
                        'type': 'string',
                        'description': 'The title of the main item.'
                      },
                      'nutritionData': {
                        'type': 'object',
                        'required': ['calories', 'carbs', 'protein', 'fats'],
                        'properties': {
                          'fats': {
                            'type': 'number',
                            'description': 'Fats contained in the main item.'
                          },
                          'carbs': {
                            'type': 'number',
                            'description':
                                'Carbohydrates contained in the main item.'
                          },
                          'protein': {
                            'type': 'number',
                            'description': 'Protein contained in the main item.'
                          },
                          'calories': {
                            'type': 'number',
                            'description':
                                'Calories contained in the main item.'
                          }
                        },
                        'additionalProperties': false
                      }
                    },
                    'additionalProperties': false
                  },
                  'healthScore': {
                    'type': 'number',
                    'description': 'The health score of the food item.'
                  },
                  'ingredients': {
                    'type': 'array',
                    'items': {
                      'type': 'object',
                      'required': ['title', 'grams', 'nutritionData'],
                      'properties': {
                        'grams': {
                          'type': 'number',
                          'description':
                              'The weight of the ingredient in grams.'
                        },
                        'title': {
                          'type': 'string',
                          'description': 'The title of the ingredient.'
                        },
                        'nutritionData': {
                          'type': 'object',
                          'required': ['calories', 'carbs', 'protein', 'fats'],
                          'properties': {
                            'fats': {
                              'type': 'number',
                              'description': 'Fats contained in the ingredient.'
                            },
                            'carbs': {
                              'type': 'number',
                              'description':
                                  'Carbohydrates contained in the ingredient.'
                            },
                            'protein': {
                              'type': 'number',
                              'description':
                                  'Protein contained in the ingredient.'
                            },
                            'calories': {
                              'type': 'number',
                              'description':
                                  'Calories contained in the ingredient.'
                            }
                          },
                          'additionalProperties': false
                        }
                      },
                      'additionalProperties': false
                    }
                  }
                },
                'additionalProperties': false
              },
            ),
          ),
        ),
      );

      print('Received response from OpenAI $response');
      final content = response.choices.first.message.content;
      print("CONTENT: $content");
      if (content == null || content.isEmpty) {
        throw Exception('Empty response from OpenAI');
      }

      final Map<String, dynamic> jsonResponse = json.decode(content);
      print('Successfully parsed JSON response: $jsonResponse');

      return FoodInfo.fromMap(jsonResponse);
    } catch (e, stackTrace) {
      print('❌ OpenAI service error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
