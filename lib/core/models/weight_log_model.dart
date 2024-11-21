class WeightLog {
  final DateTime date;
  final double weight;

  WeightLog({
    required this.date,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
      };

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
        date: DateTime.parse(json['date']),
        weight: json['weight'].toDouble(),
      );
}
