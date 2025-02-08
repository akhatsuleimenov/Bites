// Dart imports:
import 'dart:io';
import 'dart:math' as math;

// Flutter imports:
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/llm_service.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:provider/provider.dart';
import '../painters/scan_line_painter.dart';
import '../widgets/analyzing_indicator.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  final LLMService _llmService = LLMService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isAnalyzing = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  bool _photoTaken = false;
  String? _capturedImagePath;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _progressController;
  bool _analysisComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scanLineAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.linear,
      ),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _scanLineController.dispose();
    _cameraController?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Force portrait for the entire app
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();

      // Lock both the device and camera orientation
      await Future.wait([
        _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp),
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
      ]);

      // Set initial zoom levels
      _minAvailableZoom = await _cameraController!.getMinZoomLevel();
      _maxAvailableZoom = await _cameraController!.getMaxZoomLevel();

      if (mounted) setState(() {});
    } catch (e) {
      print('Failed to initialize camera: $e');
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    print('Starting image analysis for path: ${image.path}');
    setState(() {
      _isAnalyzing = true;
      _photoTaken = true;
      _capturedImagePath = image.path;
      _analysisComplete = false;
    });

    // Start animations
    _progressController.reset();
    _progressController.forward();
    _scanLineController.reset();
    _scanLineController.repeat(); // Make scan line repeat during analysis

    try {
      // print('Calling LLM service...');
      // final results = await _llmService.analyzeFoodImage(image.path);
      // print('Analysis complete. Results: $results');

      // Simulate longer API delay for testing (10 seconds)
      await Future.delayed(const Duration(seconds: 5));

      final results = FoodInfo(
        mainItem: Ingredient(
          title: "Fettuccine Pasta",
          grams: 100,
          nutritionData: NutritionData(
            calories: 350,
            protein: 12,
            carbs: 65,
            fats: 8,
          ),
        ),
        ingredients: [
          Ingredient(
            title: "pasta",
            grams: 100,
            nutritionData:
                NutritionData(calories: 350, protein: 12, carbs: 65, fats: 8),
          ),
        ],
        healthScore: 65,
      );

      setState(() => _analysisComplete = true);
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/food-logging/results',
        arguments: {
          'imagePath': image.path,
          'resultFoodInfo': results,
        },
      );
    } catch (e) {
      print('❌ Analysis failed with error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _progressController.stop();
      _scanLineController.stop();
      setState(() {
        _isAnalyzing = false;
        _photoTaken = false;
        _capturedImagePath = null;
        _analysisComplete = false;
      });
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      await _analyzeImage(photo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to take picture. Try again later')),
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

      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      if (!mounted) return;
      print('Failed to pick image: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Try another image'),
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
                                          color: AppColors.primary,
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * _cameraController!.value.aspectRatio;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          // Force portrait when leaving
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          return true;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview or captured image
            if (_photoTaken && _capturedImagePath != null)
              Image.file(
                File(_capturedImagePath!),
                fit: BoxFit.cover,
              )
            else
              Transform.scale(
                scale: 1 / scale,
                alignment: Alignment.center,
                child: Center(
                  child: CameraPreview(
                    _cameraController!,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: (_) => _baseScale = _currentScale,
                          onScaleUpdate: (details) {
                            _currentScale = (_baseScale * details.scale)
                                .clamp(_minAvailableZoom, _maxAvailableZoom);
                            _cameraController!.setZoomLevel(_currentScale);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Overlay
            Positioned.fill(
              child: CustomPaint(
                painter: OverlayPainter(isScanning: _isAnalyzing),
              ),
            ),

            // Analyzing indicator - using the extracted widget
            AnalyzingIndicator(
              isAnalyzing: _isAnalyzing,
              analysisComplete: _analysisComplete,
              progressAnimation: _progressController,
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Add Item',
                        style: TypographyStyles.h3(color: AppColors.textWhite),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Controls
            if (!_isAnalyzing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library,
                              color: AppColors.textWhite),
                          onPressed: _pickFromGallery,
                          iconSize: 32,
                        ),
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.textWhite, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.textWhite,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.history,
                              color: AppColors.textWhite),
                          onPressed: _selectPreviousMeal,
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Scan line overlay
            if (_isAnalyzing)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _scanLineAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScanLinePainter(
                        progress: _scanLineAnimation.value,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
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

class OverlayPainter extends CustomPainter {
  final bool isScanning;

  OverlayPainter({this.isScanning = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final squareSize = size.width * 0.8;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;

    // Draw semi-transparent overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(left, top, squareSize, squareSize))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw border and corners with color based on scanning state
    final borderColor = isScanning ? AppColors.primary : Colors.white;

    // Draw corner guides
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = squareSize * 0.1;

    // Top-left corner
    final radius = cornerLength * 0.3;
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(left + radius, top + radius), radius: radius),
        math.pi,
        math.pi / 2,
        false,
        cornerPaint);
    canvas.drawLine(Offset(left + radius, top),
        Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top + radius),
        Offset(left, top + cornerLength), cornerPaint);

    // Top-right corner
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(left + squareSize - radius, top + radius),
            radius: radius),
        -math.pi / 2,
        math.pi / 2,
        false,
        cornerPaint);
    canvas.drawLine(Offset(left + squareSize - cornerLength, top),
        Offset(left + squareSize - radius, top), cornerPaint);
    canvas.drawLine(Offset(left + squareSize, top + radius),
        Offset(left + squareSize, top + cornerLength), cornerPaint);

    // Bottom-left corner
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(left + radius, top + squareSize - radius),
            radius: radius),
        math.pi / 2,
        math.pi / 2,
        false,
        cornerPaint);
    canvas.drawLine(Offset(left, top + squareSize - cornerLength),
        Offset(left, top + squareSize - radius), cornerPaint);
    canvas.drawLine(Offset(left + radius, top + squareSize),
        Offset(left + cornerLength, top + squareSize), cornerPaint);

    // Bottom-right corner
    canvas.drawArc(
        Rect.fromCircle(
            center:
                Offset(left + squareSize - radius, top + squareSize - radius),
            radius: radius),
        0,
        math.pi / 2,
        false,
        cornerPaint);
    canvas.drawLine(Offset(left + squareSize - cornerLength, top + squareSize),
        Offset(left + squareSize - radius, top + squareSize), cornerPaint);
    canvas.drawLine(Offset(left + squareSize, top + squareSize - cornerLength),
        Offset(left + squareSize, top + squareSize - radius), cornerPaint);
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) =>
      isScanning != oldDelegate.isScanning;
}
