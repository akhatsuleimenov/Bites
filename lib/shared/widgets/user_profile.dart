class UserProfile {
  String name;
  int height;
  double weight;
  bool isMetric;
  int age;
  String gender;
  int calorieAdjustment;
  double activityMultiplier;
  double targetWeight;
  String goal;
  String workoutFrequency;
  double bmr;
  double tdee;
  int dailyCalories;

  UserProfile({
    this.name = '',
    this.height = 170,
    this.weight = 70,
    this.isMetric = true,
    this.age = 25,
    this.gender = 'male',
    this.calorieAdjustment = 0,
    this.activityMultiplier = 1.2,
    this.targetWeight = 70,
    this.goal = 'lose_weight',
    this.workoutFrequency = 'light',
    this.bmr = 0,
    this.tdee = 0,
    this.dailyCalories = 0,
  });

  bool isEmpty() {
    return name.isEmpty ||
        goal.isEmpty ||
        workoutFrequency.isEmpty ||
        targetWeight == 0;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      height: map['height'] ?? 170,
      weight: map['weight'] ?? 70,
      isMetric: map['isMetric'] ?? true,
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'male',
      calorieAdjustment: map['calorieAdjustment'] ?? 0,
      activityMultiplier: map['activityMultiplier'] ?? 1.2,
      targetWeight: map['targetWeight'] ?? 70,
      goal: map['goal'] ?? 'lose_weight',
      workoutFrequency: map['workoutFrequency'] ?? 'light',
      bmr: map['bmr'] ?? 0,
      tdee: map['tdee'] ?? 0,
      dailyCalories: map['dailyCalories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'height': height,
        'weight': weight,
        'isMetric': isMetric,
        'age': age,
        'gender': gender,
        'calorieAdjustment': calorieAdjustment,
        'activityMultiplier': activityMultiplier,
        'targetWeight': targetWeight,
        'goal': goal,
        'workoutFrequency': workoutFrequency,
        'bmr': bmr,
        'tdee': tdee,
        'dailyCalories': dailyCalories,
      };
}
