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
  final Color? textColor;

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
    this.textColor,
  }) : assert(text != null || leading != null,
            'Either text or leading must be provided');

  @override
  Widget build(BuildContext context) {
    final bool isOutlined = variant == ButtonVariant.outlined;
    final buttonColor = color ??
        (isOutlined ? Colors.transparent : Theme.of(context).primaryColor);
    final textColor = this.textColor ?? AppColors.textWhite;

    return SizedBox(
      height: height ?? 50,
      width: width ?? double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: (loading || !enabled) ? null : onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                side: BorderSide(color: color ?? AppColors.buttonBorder),
                elevation: 0,
              ),
              child: _buildChild(textColor, text, leading, loading),
            )
          : ElevatedButton(
              onPressed: (loading || !enabled) ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _buildChild(textColor, text, leading, loading),
            ),
    );
  }

  static Widget _buildChild(
      Color textColor, String? text, Widget? leading, bool loading) {
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

    if (leading != null) return leading;

    return Text(
      text!,
      style: TypographyStyles.bodyBold(color: textColor),
    );
  }
}

class ChoiceButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  final Widget? leading;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? color;

  const ChoiceButton({
    super.key,
    this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.leading,
    this.width,
    this.borderRadius,
    this.color,
  }) : assert(text != null || leading != null,
            'Either text or leading must be provided');

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        enabled ? color ?? Theme.of(context).primaryColor : Colors.grey[200];
    final textColor = enabled ? color ?? Colors.white : Colors.grey[500]!;

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (loading || !enabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
        child: PrimaryButton._buildChild(textColor, text, leading, loading),
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
