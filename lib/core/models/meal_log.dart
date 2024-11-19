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

abstract class NutritionItem {
  double get quantity;
  set quantity(double value);
  double get calories;
  set calories(double value);
  double get protein;
  set protein(double value);
  double get carbs;
  set carbs(double value);
  double get fat;
  set fat(double value);
}

class FoodInfo implements NutritionItem {
  final String grade;
  final String name;
  @override
  double quantity;
  @override
  double calories;
  @override
  double carbs;
  @override
  double fat;
  @override
  double protein;
  List<Ingredient> ingredients;

  FoodInfo({
    required this.grade,
    required this.name,
    required this.quantity,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() => {
        'grade': grade,
        'name': name,
        'quantity': quantity,
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
      };

  factory FoodInfo.fromMap(Map<String, dynamic> map) {
    return FoodInfo(
      grade: map['grade'],
      name: map['name'],
      quantity: ((map['quantity'] as num).toDouble() * 10).round() / 10,
      calories: ((map['calories'] as num).toDouble() * 10).round() / 10,
      carbs: ((map['carbs'] as num).toDouble() * 10).round() / 10,
      fat: ((map['fat'] as num).toDouble() * 10).round() / 10,
      protein: ((map['protein'] as num).toDouble() * 10).round() / 10,
      ingredients: (map['ingredients'] as List)
          .map((i) => Ingredient.fromMap(i))
          .toList(),
    );
  }
}

class Ingredient implements NutritionItem {
  final String grade;
  final String name;
  @override
  double quantity;
  @override
  double calories;
  @override
  double carbs;
  @override
  double fat;
  @override
  double protein;

  Ingredient({
    required this.grade,
    required this.name,
    required this.quantity,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  Map<String, dynamic> toMap() => {
        'grade': grade,
        'name': name,
        'quantity': quantity,
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      grade: map['grade'],
      name: map['name'],
      quantity: ((map['quantity'] as num).toDouble() * 10).round() / 10,
      calories: ((map['calories'] as num).toDouble() * 10).round() / 10,
      carbs: ((map['carbs'] as num).toDouble() * 10).round() / 10,
      fat: ((map['fat'] as num).toDouble() * 10).round() / 10,
      protein: ((map['protein'] as num).toDouble() * 10).round() / 10,
    );
  }
}
