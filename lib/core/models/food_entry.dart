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

class FoodEntry {
  final String id;
  final String name;
  final int calories;
  final NutritionPlan nutritionPlan;
  final MealType mealType;
  final DateTime timestamp;
  final String imageUrl;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.nutritionPlan,
    required this.mealType,
    required this.timestamp,
    required this.imageUrl,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      nutritionPlan:
          NutritionPlan.fromJson(json['nutritionPlan'] as Map<String, dynamic>),
      mealType: MealType.values[json['mealType'] as int],
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class NutritionPlan {
  final int calories;
  final MacroNutrients macros;

  const NutritionPlan({
    required this.calories,
    required this.macros,
  });

  factory NutritionPlan.empty() => NutritionPlan(
        calories: 0,
        macros: MacroNutrients.empty(),
      );

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      calories: json['dailyCalories'] as int,
      macros: MacroNutrients(
        protein: (json['macroTargets']['protein'] as num).toDouble(),
        carbs: (json['macroTargets']['carbs'] as num).toDouble(),
        fats: (json['macroTargets']['fats'] as num).toDouble(),
      ),
    );
  }
}

class MacroNutrients {
  final double protein;
  final double carbs;
  final double fats;

  const MacroNutrients({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory MacroNutrients.empty() => const MacroNutrients(
        protein: 0,
        carbs: 0,
        fats: 0,
      );

  factory MacroNutrients.fromJson(Map<String, dynamic> json) {
    return MacroNutrients(
      protein: json['protein'] as double,
      carbs: json['carbs'] as double,
      fats: json['fats'] as double,
    );
  }
}
