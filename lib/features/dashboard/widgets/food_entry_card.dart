import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutrition_ai/core/models/food_entry.dart';

class FoodEntryCard extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback? onTap;

  const FoodEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Food Image
              if (entry.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: entry.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Icon(Icons.fastfood),
                  ),
                ),
              SizedBox(width: 12),

              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${entry.calories} cal • ${entry.nutritionPlan.macros.protein}p ${entry.nutritionPlan.macros.carbs}c ${entry.nutritionPlan.macros.fats}f',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp
              Text(
                DateFormat('HH:mm').format(entry.timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
