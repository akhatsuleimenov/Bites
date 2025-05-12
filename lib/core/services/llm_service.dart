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
      print('🔄 Running analysis with both Gemini and OpenAI in parallel...');

      final results = await Future.wait([
        _geminiService.analyzeImage(imagePath).catchError((e) {
          print('⚠️ Gemini analysis failed: $e');
          throw e; // Re-throw to handle null case properly
        }),
        _openaiService.analyzeImage(imagePath).catchError((e) {
          print('⚠️ OpenAI analysis failed: $e');
          throw e; // Re-throw to handle null case properly
        }),
      ], eagerError: false); // Don't fail fast if one fails

      final geminiResult = results[0] as FoodInfo?;
      final openaiResult = results[1] as FoodInfo?;

      if (geminiResult == null && openaiResult == null) {
        throw Exception('Both models failed. Please try again later.');
      }

      if (geminiResult != null && geminiResult.mainItem.title == "Not Food") {
        return geminiResult;
      }

      if (openaiResult != null && openaiResult.mainItem.title == "Not Food") {
        return openaiResult;
      }

      if (geminiResult != null && openaiResult != null) {
        print('✅ Both models succeeded, using AI to merge results...');
        return await _openaiService.mergeFoodInfo(geminiResult, openaiResult);
      }

      return geminiResult ?? openaiResult!;
    } catch (e, stackTrace) {
      print('❌ Analysis failed: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Sorry for the trouble. Please try again later.');
    }
  }
}
