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
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    enabled ? buttonColor : AppColors.inputBorder),
                foregroundColor: WidgetStateProperty.all(textColor),
                overlayColor: WidgetStateProperty.all(
                    AppColors.buttonPressed), // Change color on press
                shadowColor: WidgetStateProperty.all(
                    Colors.transparent), // Remove shadow when pressed
                elevation: WidgetStateProperty.all(
                    0), // No elevation even when pressed
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                  ),
                ),
              ),
              child: _buildChild(enabled ? textColor : AppColors.textSecondary,
                  text, leading, loading),
            ),
    );
  }

  static Widget _buildChild(
      Color textColor, String? text, Widget? leading, bool loading,
      {TextStyle? style}) {
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
      style: style ?? TypographyStyles.bodyBold(color: textColor),
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
  final bool? pressed;
  final Color? color;
  final IconData? icon;
  final String? subtitle;
  final bool displayCheck;

  const ChoiceButton({
    super.key,
    this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.leading,
    this.width,
    this.borderRadius,
    this.color,
    this.pressed,
    this.subtitle,
    this.displayCheck = false,
  }) : assert(text != null || leading != null,
            'Either text or leading must be provided');

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        enabled ? color ?? AppColors.textWhite : Colors.grey[200];
    final textColor =
        enabled ? color ?? AppColors.textPrimary : Colors.grey[500]!;

    return SizedBox(
      width: width ?? double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.15), // Shadow color with opacity
              spreadRadius: 0, // Spread value
              blurRadius: 2, // Blur value
              offset: Offset(0, 0), // Offset (horizontal, vertical)
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (loading || !enabled) ? null : onPressed,
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: pressed == true
                      ? AppColors.primary
                      : AppColors.buttonBorder,
                  width: 1,
                ),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(
                pressed == true ? AppColors.primary25 : buttonColor),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
            elevation: WidgetStateProperty.all(0), // No
          ),
          child: _buildChild(textColor),
        ),
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

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: pressed == true
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.grayBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon!,
            color: textColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text!,
                style: subtitle != null
                    ? TypographyStyles.bodyBold(color: textColor)
                    : TypographyStyles.bodyMedium(color: textColor),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TypographyStyles.body(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (displayCheck) ...[
          const SizedBox(width: 16),
          pressed == true
              ? Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 24,
                )
              : const SizedBox(width: 0),
        ],
      ],
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
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? AppColors.grayBackground,
      ),
      child: IconButton(
        color: color ?? AppColors.textPrimary,
        iconSize: 16,
        icon: const Icon(Icons.arrow_back),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
