// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:bytes/core/models/food_model.dart';
import 'package:bytes/core/widgets/cards.dart';

class MealLogCard extends StatelessWidget {
  final MealLog mealLog;
  final VoidCallback? onTap;

  const MealLogCard({
    super.key,
    required this.mealLog,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 4.0, top: 4.0),
      child: BaseCard(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // Food Image
              if (mealLog.imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: mealLog.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Icon(Icons.fastfood),
                  ),
                ),
              const SizedBox(width: 16),

              // Meal Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealLog.foodInfo.nutritionalInfo.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${mealLog.foodInfo.nutritionalInfo.nutritionData.calories} cal',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mealLog.mealType,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timestamp
              Text(
                DateFormat('HH:mm').format(mealLog.dateTime),
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
