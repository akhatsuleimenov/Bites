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
  final MacroNutrients macros;
  final MealType mealType;
  final DateTime timestamp;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.macros,
    required this.mealType,
    required this.timestamp,
  });
}

class DailyStats {
  final int calories;
  final MacroNutrients macros;

  const DailyStats({
    required this.calories,
    required this.macros,
  });

  factory DailyStats.empty() => DailyStats(
        calories: 0,
        macros: MacroNutrients.empty(),
      );
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
}
