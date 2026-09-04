import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../App Configuration/app_config.dart';
import '../../Controllers/Login_controller.dart';
import '../../Routes/app_routes.dart';
import '../../common/Text Fields.dart';
import '../../common/button.dart';
import '../../common/export.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with CodeAutoFill {
  var loginController = Get.put(LoginController());

  // Error and state variables
  String? _otpError;
  bool _isResending = false;
  bool _isVerifying = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;
  String? _lastAutoVerifiedOtp;

  @override
  void initState() {
    super.initState();
    loginController.hiveMethod.getUserId();
    _startResendTimer();
    listenForCode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    final smsCode = code?.trim() ?? '';
    if (smsCode.isEmpty || loginController.otpController.text == smsCode) {
      return;
    }

    loginController.otpController.text = smsCode;
    loginController.otpController.selection = TextSelection.fromPosition(
      TextPosition(offset: smsCode.length),
    );

    if (smsCode.length == 6 && !_isVerifying) {
      _lastAutoVerifiedOtp = smsCode;
      FocusScope.of(context).unfocus();
      _validateAndVerify();
    }
  }

  // Start countdown timer for resend OTP
  void _startResendTimer() {
    setState(() {
      _resendCountdown = 180; // 60 seconds countdown
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // Validation Method
  String? _validateOTP(String value) {
    if (value.isEmpty) {
      return 'OTP is required';
    }

    // Remove any spaces
    String cleanOTP = value.replaceAll(' ', '');

    // Check if OTP contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanOTP)) {
      return 'OTP should contain only numbers';
    }

    // Check OTP length (typically 4 or 6 digits)
    if (cleanOTP.length != 6) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  void _validateAndVerify() async {
    if (_isVerifying) return;

    setState(() {
      _otpError = _validateOTP(loginController.otpController.text.trim());
    });

    // If no errors, proceed with verification
    if (_otpError == null) {
      setState(() {
        _isVerifying = true;
      });

      // Call the API
      try {
        await loginController.getVerifyOtp("verifyCustomerOTP", {
          "customerId": loginController.hiveMethod.customerId,
          "otp": loginController.otpController.text.trim(),
        });

        // Use ever() or check the response
        if (loginController.verifyOtpData.value["success"] == true) {
          _performVerification();
        } else {
          setState(() {
            _otpError =
                loginController.verifyOtpData.value["message"] ??
                "Invalid OTP. Please try again.";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    }
  }

  Future<void> _performVerification() async {
    setState(() {
      _otpError = null;
    });
    if (loginController.verifyOtpData.value["data"][0]["status"] ==
        "approved") {
      print("1");
      // Clear navigation stack and go to onboarding
      Get.offAllNamed(AppRoutes.home);
    } else {
      if (AppConfig.loginRoute == "1") {
        Get.offNamedUntil(
          AppRoutes.landingPage,
          (route) => route.settings.name == AppRoutes.landingPage,
        );
      } else if (AppConfig.loginRoute == "2") {
        Get.offNamedUntil(
          AppRoutes.home,
          (route) => route.settings.name == AppRoutes.home,
        );
      } else {
        Get.offNamedUntil(
          AppRoutes.servicePage,
          (route) => route.settings.name == AppRoutes.servicePage,
          arguments: AppConfig.serviceID,
        );
        // Get.toNamed(AppRoutes.servicePage);
      }
    }
  }

  Future<void> _resendOTP() async {
    // Prevent multiple clicks
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Call the resend OTP API
      await loginController.getResendOtp("resendcustomerOTP", {
        'phone': loginController.hiveMethod.phone,
      });

      // Check if the API call was successful
      if (loginController.reSendOtpData.value["success"] == true) {
        // Clear any previous errors
        setState(() {
          _otpError = null;
          _isResending = false;
        });
        // Restart the countdown timer
        _startResendTimer();
      } else {
        // Show error message
        setState(() {
          _isResending = false;
        });

        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         loginController.reSendOtpData.value["message"] ??
        //             'Failed to resend OTP. Please try again.',
        //       ),
        //       backgroundColor: Colors.red,
        //       duration: const Duration(seconds: 2),
        //       behavior: SnackBarBehavior.floating,
        //     ),
        //   );
        // }
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _isResending = false;
      });

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('An error occurred. Please try again.'),
      //       backgroundColor: Colors.red,
      //       duration: Duration(seconds: 2),
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //   );
      // }

      print("Resend OTP Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: AppSafeArea(
        backgroundColor: Colors.white,
        child: Scaffold(
          resizeToAvoidBottomInset: true, // ✅ Changed to true
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // ✅ Add this
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo and Brand - Centered
                  Center(
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 153.61,
                      height: 55,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Center(
                    child: const Text(
                      'Empowering customers to book',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontFamily: 'Figtree-Medium',
                        fontWeight: FontWeight.w700,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  SizedBox(
                    width: double.infinity,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 21,
                          fontFamily: 'Figtree-Medium',
                          fontWeight: FontWeight.w700,
                          color: AppConfig.primaryColor,
                        ),
                        children: [
                          TextSpan(text: 'services in a '),
                          TextSpan(
                            text: 'more streamlined ',
                            style: TextStyle(color: Color(0xFFE8943A)),
                          ),
                          TextSpan(text: 'way.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Enter OTP text - Left aligned
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      color: const Color(0xFF101828),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Wrap(
                    children: [
                      Text(
                        'Enter the code sent to ',
                        style: TextStyle(
                          color: const Color(0xFF475467),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.75,
                        ),
                      ),
                      Text(
                        "+91 ${loginController.hiveMethod.phone}",
                        style: TextStyle(
                          color: const Color(0xFF156FEE),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.75,
                        ),
                      ),
                      Text(
                        'to confirm ',
                        style: TextStyle(
                          color: const Color(0xFF475467),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.75,
                        ),
                      ),
                      Text(
                        'your account.',
                        style: TextStyle(
                          color: const Color(0xFF475467),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.75,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // OTP Input field with validation
                  CustomTextField(
                    fontSize: 16,
                    fieldHeight: 48,
                    controller: loginController.otpController,
                    hintText: 'Enter OTP',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    errorText: _otpError,
                    onChanged: (value) {
                      // Clear error when user starts typing
                      if (_otpError != null) {
                        setState(() {
                          _otpError = null;
                        });
                      }

                      if (value.length < 6) {
                        _lastAutoVerifiedOtp = null;
                        return;
                      }

                      if (!_isVerifying &&
                          value.length == 6 &&
                          _lastAutoVerifiedOtp != value) {
                        _lastAutoVerifiedOtp = value;
                        FocusScope.of(context).unfocus();
                        _validateAndVerify();
                      }
                    },
                    onSubmitted: (value) {
                      // Trigger validation when user presses Done
                      _validateAndVerify();
                    },
                  ),

                  const SizedBox(height: 20),

                  // Resend OTP section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          color: const Color(0xFF475467),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_resendCountdown > 0)
                        Text(
                          'Resend in ${_resendCountdown}s',
                          style: TextStyle(
                            color: const Color(0xFF98A2B3),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _isResending ? null : _resendOTP,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: _isResending
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConfig.primaryColor,
                                    ),
                                  ),
                                )
                              : ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFFE8943A),
                                          Color(0xFFE8943A),
                                        ],
                                      ).createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: const Text(
                                    'Resend',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white),
                    child: CustomButton(
                      text: _isVerifying ? "Verifying..." : "Verify",
                      isLoading: _isVerifying,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isVerifying ? null : _validateAndVerify,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Sheet Button
        ),
      ),
    );
  }
}
