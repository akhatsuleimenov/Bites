// Flutter imports:
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> goals = [
  {
    'id': 'lose_weight',
    'title': 'Lose Weight',
    'subtitle': 'I want to reduce my body weight',
    'icon': Icons.trending_down,
    'calorieAdjustment': -500, // 500 calorie deficit
  },
  {
    'id': 'maintain',
    'title': 'Maintain Weight',
    'subtitle': 'I\'m happy with my current weight',
    'icon': Icons.balance,
    'calorieAdjustment': 0,
  },
  {
    'id': 'lean_bulk',
    'title': 'Lean Bulk',
    'subtitle': 'I want to gain muscle mass without gaining fat',
    'icon': Icons.fitness_center,
    'calorieAdjustment': 300, // Moderate surplus for muscle gain
  },
  {
    'id': 'gain_weight',
    'title': 'Gain Weight',
    'subtitle': 'I want to increase my body weight',
    'icon': Icons.trending_up,
    'calorieAdjustment': 500, // 500 calorie surplus
  },
];

final List<Map<String, dynamic>> frequencies = [
  {
    'id': 'sedentary',
    'title': 'Sedentary',
    'subtitle': 'Little to no exercise',
    'icon': Icons.weekend,
    'multiplier': 1.2,
  },
  {
    'id': 'light',
    'title': '1-2 times a week',
    'subtitle': 'Light exercise',
    'icon': Icons.directions_walk,
    'multiplier': 1.375,
  },
  {
    'id': 'moderate',
    'title': '3-5 times a week',
    'subtitle': 'Moderate exercise',
    'icon': Icons.directions_run,
    'multiplier': 1.55,
  },
  {
    'id': 'active',
    'title': '6-7 times a week',
    'subtitle': 'Very active',
    'icon': Icons.fitness_center,
    'multiplier': 1.725,
  },
  {
    'id': 'athlete',
    'title': 'Athlete',
    'subtitle': 'Professional/Intense training',
    'icon': Icons.sports_gymnastics,
    'multiplier': 1.9,
  },
];
