import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controllers/task_management_controller.dart';
import '../../common/app_toast.dart';
import 'task_theme.dart';

class TaskLoginScreen extends StatefulWidget {
  const TaskLoginScreen({super.key});

  @override
  State<TaskLoginScreen> createState() => _TaskLoginScreenState();
}

class _TaskLoginScreenState extends State<TaskLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  final TaskManagementController _controller = Get.put(
    TaskManagementController(),
    permanent: true,
  );

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _controller.login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaskTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Top Badge & Logo Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: TaskTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: TaskTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: TaskTheme.primary,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Field Tech Portal',
                            style: GoogleFonts.inter(
                              color: TaskTheme.primary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Obx(
                        () => Icon(
                          _controller.isOnline.value
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: _controller.isOnline.value
                              ? TaskTheme.statusCompleted
                              : TaskTheme.textMuted,
                        ),
                      ),
                      onPressed: () => _controller.toggleOnlineStatus(),
                      tooltip: 'Toggle Network Simulation',
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // Welcome Texts
                Text(
                  'Welcome Back 👋',
                  style: TaskTheme.headingBold(size: 26.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign in to access your assigned work orders, schedule & offline sync.',
                  style: TaskTheme.bodyRegular(size: 14.sp),
                ),

                SizedBox(height: 36.h),

                // Mobile / Email Input
                Text(
                  'Mobile Number or Email',
                  style: TaskTheme.headingSemiBold(size: 13.sp),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  style: TaskTheme.bodyMedium(size: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter mobile or email',
                    hintStyle: TaskTheme.bodyRegular(
                      size: 14.sp,
                      color: TaskTheme.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: TaskTheme.textSecondary,
                      size: 20.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter mobile number or email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Password Input
                Text('Password', style: TaskTheme.headingSemiBold(size: 13.sp)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TaskTheme.bodyMedium(size: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TaskTheme.bodyRegular(
                      size: 14.sp,
                      color: TaskTheme.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: TaskTheme.textSecondary,
                      size: 20.sp,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TaskTheme.textSecondary,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.borderSubtle,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: TaskTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                // Remember me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24.w,
                          width: 24.w,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: TaskTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? true;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Remember me',
                          style: TaskTheme.bodyRegular(
                            size: 13.sp,
                            color: TaskTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          AppToast.info(
                            'Reset Link Sent',
                            'Password reset instructions sent to your registered mobile.',
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: TaskTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Sign In Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading.value
                          ? null
                          : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TaskTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: TaskTheme.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Sign In to Work Orders',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward_rounded, size: 18.sp),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 36.h),

                // Offline demo mode intentionally contains no production credentials.
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: TaskTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            color: TaskTheme.statusInProgress,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Quick Demo Account',
                            style: TaskTheme.headingSemiBold(size: 13.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _controller.loginDemoMode(
                            email: 'bharathi@gmail.com',
                            name: 'Bharathi Raman',
                          ),
                          icon: Icon(
                            Icons.offline_bolt_outlined,
                            size: 16.sp,
                            color: TaskTheme.primary,
                          ),
                          label: Text(
                            'Explore App in Offline Demo Mode',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: TaskTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
