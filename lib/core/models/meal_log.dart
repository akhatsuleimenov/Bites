import 'package:cloud_firestore/cloud_firestore.dart';

class MealLog {
  final String? id;
  final String userId;
  final DateTime dateTime;
  final String mealType;
  final String imagePath;
  final double totalCalories;
  final String analysisId;
  final List<FoodItem> items;

  MealLog({
    this.id,
    required this.userId,
    required this.dateTime,
    required this.mealType,
    required this.imagePath,
    required this.totalCalories,
    required this.analysisId,
    required this.items,
  });

  Map<String, dynamic> toFirestore() {
    print("toFirestore");
    return {
      'userId': userId,
      'dateTime': Timestamp.fromDate(dateTime),
      'mealType': mealType,
      'imagePath': imagePath,
      'totalCalories': totalCalories,
      'analysisId': analysisId,
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }

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
      totalCalories: data['totalCalories'],
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
  final Map<String, double> nutrition;
  final List<Ingredient> ingredients;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.grade,
    required this.nutrition,
    required this.ingredients,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'grade': grade,
      'nutrition': nutrition,
      'ingredients': ingredients.map((i) => i.toFirestore()).toList(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'],
      quantity: map['quantity'],
      grade: map['grade'],
      nutrition: Map<String, double>.from(map['nutrition']),
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
  final Map<String, double> nutrition;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.grade,
    required this.nutrition,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'grade': grade,
      'nutrition': nutrition,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'],
      quantity: map['quantity'],
      grade: map['grade'],
      nutrition: Map<String, double>.from(map['nutrition']),
    );
  }
}
