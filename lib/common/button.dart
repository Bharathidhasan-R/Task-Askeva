import 'package:flutter/material.dart';

import '../App Configuration/app_config.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool showIconLeading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final FontWeight? fontWeight;
  final double? fontSize;
  EdgeInsets? contentPadding=EdgeInsets.symmetric(vertical: 16);

   CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.showIconLeading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.disabledColor,
    this.borderRadius,
    this.elevation,
    this.fontWeight,
    this.fontSize,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(),
            foregroundColor: textColor,
            disabledBackgroundColor: disabledColor ?? Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
            padding: contentPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? _getBorderRadius(),
            ),
            elevation: elevation ?? _getElevation(),
            shadowColor: Colors.transparent,
          ),
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIconLeading && icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 16,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
              ),
              if (!showIconLeading && icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return backgroundColor ?? AppConfig.primaryColor;
      case ButtonType.secondary:
        return backgroundColor ?? Colors.grey[600];
      case ButtonType.outline:
        return backgroundColor ?? AppConfig.primaryColor;
      case ButtonType.danger:
        return backgroundColor ?? Colors.red;
      case ButtonType.success:
        return backgroundColor ?? Colors.green;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return BorderRadius.circular(4);
      case ButtonType.outline:
        return BorderRadius.circular(4);
    }
  }

  double _getElevation() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return elevation ?? 2;
      case ButtonType.outline:
        return 0;
    }
  }
}

enum ButtonType { primary, secondary, outline, danger, success }