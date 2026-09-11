import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;

  const AppSafeArea({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBrightness =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: iconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemStatusBarContrastEnforced: false,
        // systemNavigationBarColor: backgroundColor,
        // systemNavigationBarDividerColor: backgroundColor,
        // systemNavigationBarIconBrightness: iconBrightness,
        // systemNavigationBarContrastEnforced: false,
      ),
      child: ColoredBox(
        color: backgroundColor,
        child: SafeArea(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          minimum: minimum,
          maintainBottomViewPadding: maintainBottomViewPadding,
          child: child,
        ),
      ),
    );
  }
}
