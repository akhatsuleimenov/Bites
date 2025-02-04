// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final bool showVisibilityToggle;
  final TextInputType? keyboardType;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Widget? prefixIcon;

  const InputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.showVisibilityToggle = false,
    this.keyboardType,
    this.borderRadius,
    this.fillColor,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.inputBorder,
          ),
        ),
        filled: true,
        fillColor: fillColor ?? Colors.transparent,
        prefixIcon: prefixIcon,
        suffixIcon: showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12.0,
          height: 0.8,
        ),
        errorMaxLines: 1,
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
