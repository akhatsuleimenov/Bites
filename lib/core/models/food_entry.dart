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

  // factory NutritionPlan.fromJson(Map<String, dynamic> json) {
  //   return NutritionPlan(
  //     calories: json['dailyCalories'] as int,
  //     macros: MacroNutrients(
  //       protein: (json['macroTargets']['protein'] as num).toDouble(),
  //       carbs: (json['macroTargets']['carbs'] as num).toDouble(),
  //       fats: (json['macroTargets']['fats'] as num).toDouble(),
  //     ),
  //   );
  // }
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

  // factory MacroNutrients.fromJson(Map<String, dynamic> json) {
  //   return MacroNutrients(
  //     protein: json['protein'] as double,
  //     carbs: json['carbs'] as double,
  //     fats: json['fats'] as double,
  //   );
  // }
}
