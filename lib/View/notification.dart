import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

class OtpNotification {
  static void show(BuildContext context, String otp) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _OtpNotificationWidget(
        otp: otp,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _OtpNotificationWidget extends StatefulWidget {
  final String otp;
  final VoidCallback onDismiss;

  const _OtpNotificationWidget({
    required this.otp,
    required this.onDismiss,
  });

  @override
  State<_OtpNotificationWidget> createState() => _OtpNotificationWidgetState();
}

class _OtpNotificationWidgetState extends State<_OtpNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _timer;
  Timer? _dismissTimer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animController);

    _animController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _dismiss();
      }
    });

    _dismissTimer = Timer(const Duration(seconds: 30), _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    _dismissTimer?.cancel();
    _animController.reverse().then((_) => widget.onDismiss());
  }

  void _copyOtp() {
    Clipboard.setData(ClipboardData(text: widget.otp));
    Get.showSnackbar(
      GetSnackBar(
        message: 'Copied',
        duration: const Duration(milliseconds: 800),
        backgroundColor: const Color(0xFF101828),
        margin: const EdgeInsets.all(16),
        borderRadius: 6,
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF101828),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // OTP Code
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'OTP: ',
                          style: TextStyle(
                            fontFamily: 'Figtree-Medium',
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.otp,
                          style: const TextStyle(
                            fontFamily: 'Figtree-Medium',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Copy button
                  InkWell(
                    onTap: _copyOtp,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8943A), Color(0xFFE8943A)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_remainingSeconds}s',
                          style: const TextStyle(
                            fontFamily: 'Figtree-Medium',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Close button
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}