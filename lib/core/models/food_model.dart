// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MealLog {
  final String? id;
  final String userId;
  DateTime dateTime;
  final String imagePath;
  final String analysisId;
  FoodInfo foodInfo;

  MealLog({
    this.id,
    required this.userId,
    required this.dateTime,
    required this.imagePath,
    String? analysisId,
    required this.foodInfo,
  }) : analysisId = analysisId ?? const Uuid().v4();

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'dateTime': Timestamp.fromDate(dateTime),
        'imagePath': imagePath,
        'analysisId': analysisId,
        'foodInfo': foodInfo.toMap(),
      };

  factory MealLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return MealLog(
      id: snapshot.id,
      userId: data['userId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      imagePath: data['imagePath'],
      analysisId: data['analysisId'],
      foodInfo: FoodInfo.fromMap(data['foodInfo']),
    );
  }
}

class FoodInfo {
  final double healthScore;
  final double confidence;
  final Ingredient mainItem;
  final List<Ingredient> ingredients;

  FoodInfo({
    required this.healthScore,
    required this.confidence,
    required this.mainItem,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() => {
        'healthScore': healthScore,
        'confidence': confidence,
        'mainItem': mainItem.toMap(),
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
      };

  factory FoodInfo.fromMap(Map<String, dynamic> map) {
    return FoodInfo(
      healthScore: map['healthScore'].toDouble(),
      confidence: map['confidence'].toDouble(),
      mainItem: Ingredient.fromMap(map['mainItem']),
      ingredients: (map['ingredients'] as List)
          .map((i) => Ingredient.fromMap(i))
          .toList(),
    );
  }

  static FoodInfo average(List<FoodInfo> sources) {
    final avg = (num Function(FoodInfo f) getter) =>
        sources.map(getter).reduce((a, b) => a + b) / sources.length;

    return FoodInfo(
      mainItem: Ingredient(
        title: sources[0].mainItem.title,
        grams: avg((f) => f.mainItem.grams),
        nutritionData: NutritionData(
          calories: avg((f) => f.mainItem.nutritionData.calories),
          carbs: avg((f) => f.mainItem.nutritionData.carbs),
          protein: avg((f) => f.mainItem.nutritionData.protein),
          fats: avg((f) => f.mainItem.nutritionData.fats),
        ),
      ),
      healthScore: avg((f) => f.healthScore),
      confidence: avg((f) => f.confidence),
      ingredients: sources[0].ingredients, // You could also merge these.
    );
  }

  factory FoodInfo.empty() => FoodInfo(
        healthScore: 0,
        confidence: 0,
        mainItem: Ingredient.empty(),
        ingredients: [],
      );
}

class Ingredient {
  String title;
  double grams;
  final NutritionData nutritionData;

  Ingredient({
    required this.title,
    required this.grams,
    required this.nutritionData,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'grams': grams,
        'nutritionData': nutritionData.toMap(),
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      title: map['title'],
      grams: map['grams'].toDouble(),
      nutritionData: NutritionData.fromMap(map['nutritionData']),
    );
  }

  factory Ingredient.empty() =>
      Ingredient(title: '', grams: 0.0, nutritionData: NutritionData.empty());
}

class NutritionData {
  double calories;
  double protein;
  double carbs;
  double fats;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory NutritionData.empty() => NutritionData(
        calories: 0.0,
        protein: 0.0,
        carbs: 0.0,
        fats: 0.0,
      );

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };

  factory NutritionData.fromMap(Map<String, dynamic> map) {
    return NutritionData(
      calories: map['calories'].toDouble(),
      protein: map['protein'].toDouble(),
      carbs: map['carbs'].toDouble(),
      fats: map['fats'].toDouble(),
    );
  }
}
