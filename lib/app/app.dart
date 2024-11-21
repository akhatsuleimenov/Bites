// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bytes/app/routes.dart';
import 'package:bytes/core/auth/auth_wrapper.dart';
import 'package:bytes/core/themes/app_theme.dart';

class BytesApp extends StatelessWidget {
  const BytesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bytes.',
      theme: AppTheme.lightTheme,
      home: AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
