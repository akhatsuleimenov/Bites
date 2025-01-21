// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/gemini_service.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:provider/provider.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiSerivce _geminiService = GeminiSerivce();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isAnalyzing = false;

  Future<void> _analyzeImage(XFile image) async {
    print('Starting image analysis for path: ${image.path}');
    setState(() => _isAnalyzing = true);

    try {
      print('Calling Gemini service...');
      final results = await _geminiService.analyzeImage(image.path);
      print('Gemini analysis complete. Results: ${results}');

      if (!mounted) {
        print('Widget not mounted after analysis, returning');
        return;
      }

      Navigator.pushNamed(
        context,
        '/food-logging/results',
        arguments: {
          'imagePath': image.path,
          'resultFoodInfo': results,
        },
      );
    } on Exception catch (e) {
      print('❌ Analysis failed with error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      print('Analysis process complete');
      setState(() => _isAnalyzing = false);
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      if (!mounted) return false;

      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'We need access to your camera so that you can take photos of your meals directly within the app.\nFor example, you can snap a picture of your breakfast to track your nutrition and receive personalized meal suggestions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    return true;
  }

  Future<void> _takePicture() async {
    try {
      final hasPermission = await _requestCameraPermission();

      if (!hasPermission) return;

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (photo != null) {
        await _analyzeImage(photo);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take picture: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          if (result.isDenied) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'We need access to your photo library so that you can select existing meal images and add them to your food log.\nThis helps you keep a comprehensive visual record of what you eat over time.',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _selectPreviousMeal() async {
    try {
      final appController = context.read<AppController>();
      // Get all meals from the last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final meals = (await _firebaseService
              .getMealLogsStream(
                  userId: appController.userId,
                  currentDate: now,
                  pastDate: thirtyDaysAgo)
              .first)
          .reversed
          .toList();

      if (!mounted) return;

      final selectedMeal = await showDialog<MealLog>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Previous Meals',
                      style: AppTypography.headlineSmall
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: meals.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return InkWell(
                      onTap: () => Navigator.pop(context, meal),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                              ),
                              child: meal.imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        meal.imagePath,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.fastfood, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.foodInfo.mainItem.title,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${meal.foodInfo.mainItem.nutritionData.calories.round()} cal',
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDateTime(meal.dateTime),
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      if (selectedMeal != null) {
        Navigator.pushNamed(
          context,
          '/food-logging/results',
          arguments: {
            'imagePath': selectedMeal.imagePath,
            'resultFoodInfo': selectedMeal.foodInfo,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load previous meals: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  'Take a photo of your meal',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Our AI will analyze the image and\nestimate the calories',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Take Photo',
                        onPressed: _takePicture,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          side: BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                        onPressed: _pickFromGallery,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library),
                              SizedBox(width: 8),
                              Text('Gallery'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    side: BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: _selectPreviousMeal,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('Use Previous Meal'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing image...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
