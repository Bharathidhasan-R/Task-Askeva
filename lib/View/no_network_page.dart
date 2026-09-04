import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../App Configuration/app_config.dart';
import '../common/button.dart';

class NoNetworkPage extends StatefulWidget {
  const NoNetworkPage({
    super.key,
    required this.onRetry,
    this.isChecking = false,
  });

  final Future<void> Function() onRetry;
  final bool isChecking;

  @override
  State<NoNetworkPage> createState() => _NoNetworkPageState();
}

class _NoNetworkPageState extends State<NoNetworkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isChecking) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(NoNetworkPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecking && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isChecking && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      // WiFi Icon with pulse animation
                      _buildAnimatedIcon(),
                      SizedBox(height: 22.h),
                      Image.asset(
                        'assets/img/logo.png',
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'No Internet Connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Figtree-Medium',
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Please check your Wi-Fi or mobile data and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontFamily: 'Figtree-Medium',
                          color: const Color(0xFF5E6B78),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      // Button with loading state
                      CustomButton(
                        text: "Try Again",
                        onPressed: widget.isChecking ? null : () => widget.onRetry(),
                        fontSize: 15,
                        height: 46,
                        isLoading: widget.isChecking,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Loading status text
                      if (widget.isChecking) ...[
                        SizedBox(height: 16.h),
                        Text(
                          'Checking connection...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Figtree-Medium',
                            color: AppConfig.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Full page loading overlay
          if (widget.isChecking)
            Positioned.fill(
              child: _buildLoadingOverlay(),
            ),
        ],
      ),
    );
  }

  /// Animated WiFi icon with pulse effect when checking
  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isChecking
              ? 1.0 + (_pulseController.value * 0.08)
              : 1.0,
          child: child,
        );
      },
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFEFE1),
          boxShadow: widget.isChecking
              ? [
            BoxShadow(
              color: AppConfig.secondaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Icon(
          Icons.wifi_off_rounded,
          size: 42.sp,
          color: AppConfig.secondaryColor,
        ),
      ),
    );
  }

  /// Semi-transparent overlay with loading animation
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading dots
          _buildLoadingDots(),
          SizedBox(height: 20.h),
          Text(
            'Checking your connection',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Figtree-Medium',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Animated loading dots indicator
  Widget _buildLoadingDots() {
    return SizedBox(
      width: 60.w,
      height: 30.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
              (index) => AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              // Calculate delay for each dot
              final delay = index * 0.33;
              final animationValue =
                  (_pulseController.value + delay) % 1.0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Transform.translate(
                  offset: Offset(0, -animationValue * 12.h),
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}