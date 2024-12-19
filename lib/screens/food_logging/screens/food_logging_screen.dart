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
import 'package:bites/core/services/foodvisor_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final ImagePicker _picker = ImagePicker();
  final FoodvisorService _foodvisorService = FoodvisorService();
  bool _isAnalyzing = false;

  Future<void> _analyzeImage(XFile image) async {
    setState(() => _isAnalyzing = true);

    try {
      final results = await _foodvisorService.analyzeImage(File(image.path));
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/food-logging/results',
        arguments: {
          'imagePath': image.path,
          'analysisResults': results,
        },
      );
    } on FoodvisorException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      print('FoodvisorException: ${e}');
    } finally {
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
}
