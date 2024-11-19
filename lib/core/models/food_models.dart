// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class MealLog {
  final String? id;
  final String userId;
  DateTime dateTime;
  String mealType;
  final String imagePath;
  final String analysisId;
  FoodInfo foodInfo;

  MealLog({
    this.id,
    required this.userId,
    required this.dateTime,
    required this.mealType,
    required this.imagePath,
    required this.analysisId,
    required this.foodInfo,
  });

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'dateTime': Timestamp.fromDate(dateTime),
        'mealType': mealType,
        'imagePath': imagePath,
        'analysisId': analysisId,
        'foodInfo': foodInfo.toMap(),
      };

  factory MealLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return MealLog(
      id: snapshot.id,
      userId: data['userId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      mealType: data['mealType'],
      imagePath: data['imagePath'],
      analysisId: data['analysisId'],
      foodInfo: FoodInfo.fromMap(data['foodInfo']),
    );
  }
}

class FoodInfo {
  final NutritionalInfo nutritionalInfo;
  List<NutritionalInfo> ingredients;

  FoodInfo({
    required this.nutritionalInfo,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() => {
        'nutritionalInfo': nutritionalInfo.toMap(),
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
      };

  factory FoodInfo.fromMap(Map<String, dynamic> map) {
    return FoodInfo(
      nutritionalInfo: NutritionalInfo.fromMap(map['nutritionalInfo']),
      ingredients: (map['ingredients'] as List)
          .map((i) => NutritionalInfo.fromMap(i))
          .toList(),
    );
  }
}

class NutritionalInfo {
  final String grade;
  final String name;
  double quantity;
  NutritionData nutritionData;

  NutritionalInfo({
    required this.grade,
    required this.name,
    required this.quantity,
    required this.nutritionData,
  });

  Map<String, dynamic> toMap() => {
        'grade': grade,
        'name': name,
        'quantity': quantity,
        'nutritionData': nutritionData.toMap(),
      };

  factory NutritionalInfo.fromMap(Map<String, dynamic> map) {
    return NutritionalInfo(
      grade: map['grade'],
      name: map['name'],
      quantity: ((map['quantity'] as num).toDouble() * 10).round() / 10,
      nutritionData: NutritionData.fromMap(map['nutritionData']),
    );
  }
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

  factory NutritionData.fromMap(Map<String, dynamic> map) => NutritionData(
        calories: map['calories'],
        protein: map['protein'],
        carbs: map['carbs'],
        fats: map['fats'],
      );
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}
