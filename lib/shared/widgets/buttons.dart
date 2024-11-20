// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  final Widget? leading;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.leading,
    this.width,
    this.height,
  }) : assert(text != null || leading != null,
            'Either text or leading must be provided');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 56,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (loading || !enabled) ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : leading ??
                Text(
                  text!,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (color ?? Colors.grey[200])?.withOpacity(0.8),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
