// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/gemini_service.dart';
import 'package:bites/core/services/openai_service.dart';

/// Service responsible for orchestrating LLM model calls.
/// Uses Gemini as primary and OpenAI as fallback.
class LLMService {
  final GeminiSerivce _geminiService;
  final OpenAIService _openaiService;

  LLMService({
    GeminiSerivce? geminiService,
    OpenAIService? openaiService,
  })  : _geminiService = geminiService ?? GeminiSerivce(),
        _openaiService = openaiService ?? OpenAIService();

  /// Analyzes a food image using available LLM models.
  /// First attempts to use Gemini, falls back to OpenAI on any error.
  ///
  /// [imagePath] - Path to the image file to analyze
  /// Returns [FoodInfo] containing the analysis results
  /// Throws if both services fail
  Future<FoodInfo> analyzeFoodImage(String imagePath) async {
    try {
      print('🤖 Attempting analysis with Gemini...');
      return await _geminiService.analyzeImage(imagePath);
    } catch (e, stackTrace) {
      print('❌ Gemini analysis failed: $e');
      print('Stack trace: $stackTrace');

      print('🔄 Falling back to OpenAI...');
      try {
        return await _openaiService.analyzeImage(imagePath);
      } catch (openaiError, openaiStackTrace) {
        print('❌ OpenAI fallback failed: $openaiError');
        print('Stack trace: $openaiStackTrace');
        throw Exception('Sorry for the trouble. Please try again later.');
      }
    }
  }
}
