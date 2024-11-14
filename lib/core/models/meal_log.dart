// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class MealLog {
  final String? id;
  final String userId;
  final DateTime dateTime;
  final String mealType;
  final String imagePath;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String analysisId;
  final List<FoodItem> items;

  const MealLog({
    this.id,
    required this.userId,
    required this.dateTime,
    required this.mealType,
    required this.imagePath,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.analysisId,
    required this.items,
  });

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'dateTime': Timestamp.fromDate(dateTime),
        'mealType': mealType,
        'imagePath': imagePath,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'analysisId': analysisId,
        'items': items.map((item) => item.toFirestore()).toList(),
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
      totalCalories: (data['totalCalories'] as num).toDouble(),
      totalProtein: (data['totalProtein'] as num).toDouble(),
      totalCarbs: (data['totalCarbs'] as num).toDouble(),
      totalFat: (data['totalFat'] as num).toDouble(),
      analysisId: data['analysisId'],
      items: (data['items'] as List)
          .map((item) => FoodItem.fromMap(item))
          .toList(),
    );
  }
}

class FoodItem {
  final String name;
  final double quantity;
  final String grade;
  final Map<String, double> totalNutrition;
  final List<Ingredient> ingredients;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.grade,
    required this.totalNutrition,
    required this.ingredients,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'grade': grade,
      'totalNutrition': totalNutrition,
      'ingredients': ingredients.map((i) => i.toFirestore()).toList(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'],
      quantity: map['quantity'],
      grade: map['grade'],
      totalNutrition: Map<String, double>.from(map['totalNutrition']),
      ingredients: (map['ingredients'] as List)
          .map((i) => Ingredient.fromMap(i))
          .toList(),
    );
  }
}

class Ingredient {
  final String name;
  final double quantity;
  final String grade;
  final Map<String, double> totalNutrition;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.grade,
    required this.totalNutrition,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'grade': grade,
      'totalNutrition': totalNutrition,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'],
      quantity: map['quantity'],
      grade: map['grade'],
      totalNutrition: Map<String, double>.from(map['totalNutrition']),
    );
  }
}
