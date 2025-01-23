// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';

enum ButtonVariant {
  filled,
  outlined,
}

class PrimaryButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  final Widget? leading;
  final double? width;
  final double? height;
  final ButtonVariant variant;
  final BorderRadius? borderRadius;
  final Color? color;

  const PrimaryButton({
    super.key,
    this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.leading,
    this.width,
    this.height,
    this.variant = ButtonVariant.filled,
    this.borderRadius,
    this.color,
  }) : assert(text != null || leading != null,
            'Either text or leading must be provided');

  @override
  Widget build(BuildContext context) {
    final bool isOutlined = variant == ButtonVariant.outlined;
    final buttonColor = color ??
        (isOutlined ? Colors.transparent : Theme.of(context).primaryColor);
    final textColor = color ?? (isOutlined ? Colors.black : Colors.white);

    return SizedBox(
      height: height ?? 56,
      width: width ?? double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: (loading || !enabled) ? null : onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
                side: BorderSide(color: color ?? AppColors.buttonBorder),
              ),
              child: _buildChild(textColor),
            )
          : ElevatedButton(
              onPressed: (loading || !enabled) ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
              ),
              child: _buildChild(textColor),
            ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (loading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: textColor,
          strokeWidth: 2,
        ),
      );
    }

    if (leading != null) return leading!;

    return Text(
      text!,
      style: TypographyStyles.bodyBold(color: textColor),
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
