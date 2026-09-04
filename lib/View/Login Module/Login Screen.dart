// import 'package:vayil_vendor/Routes/app_routes.dart';
// import 'package:vayil_vendor/common/Widgets/button.dart';
//
// import '../../App Configuration/app_config.dart';
// import '../../common/Widgets/Text Fields.dart';
// import '../../common/export.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
// // Error text variables
//   String? _emailError;
//   String? _passwordError;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   // Validation Methods
//   String? _validateEmailOrUsername(String value) {
//     if (value.isEmpty) {
//       return 'Email, phone or username is required';
//     }
//
//     // Check if it's an email format
//     if (value.contains('@')) {
//       final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//       if (!emailRegex.hasMatch(value)) {
//         return 'Please enter a valid email address';
//       }
//     }
//     // Check if it's a phone number
//     else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
//       if (value.length < 10) {
//         return 'Phone number must be at least 10 digits';
//       }
//     }
//     // Username validation
//     else {
//       if (value.length < 3) {
//         return 'Username must be at least 3 characters';
//       }
//     }
//
//     return null;
//   }
//
//   String? _validatePassword(String value) {
//     if (value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//
//   void _validateForm() {
//     setState(() {
//       _emailError = _validateEmailOrUsername(_emailController.text.trim());
//       _passwordError = _validatePassword(_passwordController.text);
//     });
//
//     // If no errors, proceed with login
//     if (_emailError == null && _passwordError == null) {
//       _performLogin();
//     }
//   }
//
//   void _performLogin() {
//     // Clear any existing errors
//     setState(() {
//       _emailError = null;
//       _passwordError = null;
//     });
//
//     // TODO: Add your login API call here
//     // For now, navigate to main page
//     Get.toNamed(AppRoutes.mainPage);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//       resizeToAvoidBottomInset: false,
//         backgroundColor: Colors.white,
//         body:
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 95),
//
//                     // Logo and Brand
//                     Center(
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/img/logo.png',
//                             width: 153.61,
//                             height: 55,
//                             fit: BoxFit.contain,
//                           ),
//                           const SizedBox(height: 40),
//                           // Tagline
//                           const Text(
//                             'Get discovered. Get booked.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontFamily: 'Figtree-Medium',
//                               fontWeight: FontWeight.w700,
//                               color: AppConfig.primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Text(
//                                 'Grow your business with ',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontFamily: 'Figtree-Medium',
//                                   fontWeight: FontWeight.w700,
//                                   color: AppConfig.primaryColor,
//                                 ),
//                               ),
//                               Text(
//                                 'Vayil',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontFamily: 'Figtree-Medium',
//                                   fontWeight: FontWeight.w700,
//                                   color: AppConfig.primaryColor1,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 80),
//
//                     // Sign in text
//                     Text(
//                       'Sign in',
//                       style: TextStyle(
//                         color: const Color(0xFF101828) /* color-grey-900 */,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w500,
//                         height: 1.40,
//                       ),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // Email/Username field
//                     CustomTextField(
//                       fontSize: 16,
//                       fieldHeight: 48,
//                       controller: _emailController,
//                       hintText: 'Email or phone or username',
//                       keyboardType: TextInputType.emailAddress,
//                       textInputAction: TextInputAction.next,
//                       errorText: _emailError,
//                       onChanged: (value) {
//                         // Clear error when user starts typing
//                         if (_emailError != null) {
//                           setState(() {
//                             _emailError = null;
//                           });
//                         }
//                       },
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // Password field
//                     CustomTextField(
//                       fontSize: 16,
//                       fieldHeight: 48,
//                       controller: _passwordController,
//                       hintText: 'Password',
//                       obscureText: true,
//                       textInputAction: TextInputAction.done,
//                       errorText: _passwordError,
//                       onChanged: (value) {
//                         // Clear error when user starts typing
//                         if (_passwordError != null) {
//                           setState(() {
//                             _passwordError = null;
//                           });
//                         }
//                       },
//                       onSubmitted: (value) {
//                         // Trigger validation when user presses Done
//                         _validateForm();
//                       },
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     // Forgot password
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           minimumSize: const Size(0, 0),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: ShaderMask(
//                           shaderCallback: (bounds) => const LinearGradient(
//                             colors: [
//                               Color(0xFFE8943A),
//                               Color(0xFFE8943A),
//                             ],
//                           ).createShader(bounds), // you can pass `bounds` directly
//                           blendMode: BlendMode.srcIn, // this is the key for most gradient-text cases
//                           child: const Text(
//                             'Forgotten your Password?',
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                               color: Colors.white,          // ← THIS IS REQUIRED
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               height: 1.40,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 400),
//                     // Column(
//                     //   children: [
//                     //     CustomButton(
//                     //       text: "Sign in",
//                     //       contentPadding: const EdgeInsets.symmetric(vertical: 15),
//                     //       onPressed: () {
//                     //         // Get.toNamed(AppRoutes.mainPage);
//                     //       },
//                     //     ),
//                     //
//                     //
//                     //     const SizedBox(height: 16),
//                     //
//                     //     // Sign up link
//                     //     Row(
//                     //       mainAxisAlignment: MainAxisAlignment.center,
//                     //       children: [
//                     //         const Text(
//                     //           "Don't have Professional Account? ",
//                     //           style: TextStyle(
//                     //             color: const Color(0xFF475467) /* color-grey-600 */,
//                     //             fontSize: 14,
//                     //             // fontFamily: 'Figtree',
//                     //             fontWeight: FontWeight.w500,
//                     //             height: 1.40,
//                     //           ),
//                     //         ),
//                     //         TextButton(
//                     //           onPressed: () {
//                     //             Get.toNamed(AppRoutes.signUpScreen);
//                     //           },
//                     //           style: TextButton.styleFrom(
//                     //             padding: EdgeInsets.zero,
//                     //             minimumSize: const Size(0, 0),
//                     //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     //           ),
//                     //           child: ShaderMask(
//                     //             shaderCallback: (bounds) => const LinearGradient(
//                     //               colors: [
//                     //                 Color(0xFF5514A7),
//                     //                 Color(0xFF8F0D8A),
//                     //               ],
//                     //             ).createShader(bounds),
//                     //             blendMode: BlendMode.srcIn,               // important!
//                     //             child: const Text(
//                     //               'Sign up',
//                     //               style: TextStyle(
//                     //                 color: Colors.white,                  // must be white (or any solid color)
//                     //                 fontSize: 14,
//                     //                 fontWeight: FontWeight.w600,
//                     //                 height: 1.40,
//                     //               ),
//                     //             ),
//                     //           ),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //
//                     //
//                     //     const SizedBox(height: 20),
//                     //   ],
//                     // ),
//
//                   ],
//                 ),
//               ),
//         ),
//         bottomSheet: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Sign in button
//               CustomButton(
//                 text: "Sign in",
//                 contentPadding: const EdgeInsets.symmetric(vertical: 15),
//                 onPressed: _validateForm,
//               ),
//
//               const SizedBox(height: 16),
//
//               // Sign up link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Don't have Professional Account? ",
//                     style: TextStyle(
//                       color: const Color(0xFF475467),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       height: 1.40,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Get.toNamed(AppRoutes.signUpScreen);
//                     },
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(0, 0),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: ShaderMask(
//                       shaderCallback: (bounds) => const LinearGradient(
//                         colors: [
//                           Color(0xFFE8943A),
//                           Color(0xFFE8943A),
//                         ],
//                       ).createShader(bounds),
//                       blendMode: BlendMode.srcIn,
//                       child: const Text(
//                         'Sign up',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           height: 1.40,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import '../../App Configuration/app_config.dart';
import '../../Controllers/Login_controller.dart';
import '../../Routes/app_routes.dart';
import '../../common/Text Fields.dart';
import '../../common/button.dart';
import '../../common/export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var loginController = Get.put(LoginController());
  final FocusNode _phoneFocusNode = FocusNode();

  // Error text variable
  String? _phoneError;
  bool _isLoading = false;
  String? _lastAutoSubmittedPhone;

  @override
  void initState() {
    super.initState();
    // Initialize with default country code
    loginController.selectedCountryCode = '+91';
  }

  // Phone Validation Method
  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or special characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'Phone number should contain only digits';
    }

    // Check minimum length (most countries have at least 7 digits)
    if (cleanPhone.length < 7) {
      return 'Phone number is too short';
    }

    // Check maximum length (international numbers are usually max 15 digits)
    if (cleanPhone.length > 15) {
      return 'Phone number is too long';
    }

    // Country-specific validation
    if (loginController.selectedCountryCode == '+91') {
      // India: exactly 10 digits
      if (cleanPhone.length != 10) {
        return 'Phone number must be 10 digits';
      }
    } else if (loginController.selectedCountryCode == '+1') {
      // USA/Canada: exactly 10 digits
      if (cleanPhone.length != 10) {
        return 'Phone number must be 10 digits';
      }
    }

    return null;
  }

  Future<void> _validateAndSendOTP() async {
    if (_isLoading) return;

    final phoneNumber = loginController.loginPhoneController.text.trim();

    // Validate phone number
    setState(() {
      _phoneError = _validatePhone(phoneNumber);
    });

    // If validation passes, send OTP
    if (_phoneError == null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the OTP API
        await loginController.getVendorLogin("logincustomerWithOTP", {
          "phone": phoneNumber,
          "device_id": AppConfig.deviceId,
        });

        setState(() {
          _isLoading = false;
        });

        // Check API response
        if (loginController.loginData.value["success"] == true) {
          Get.toNamed(AppRoutes.oTPVerificationScreen);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Send OTP Error: $e");
      }
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
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
                  const SizedBox(height: 95),

                  // Logo and Brand
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/img/logo.png',
                          width: 153.61,
                          height: 55,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),

                        // Tagline
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Sign in text
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 22,
                      fontFamily: 'Figtree-Regular',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Phone number field with country code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Country Code Picker
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xffE2E2E2),
                                width: 1,
                              ),
                            ),
                            child: CountryCodePicker(
                              onChanged: (country) {
                                setState(() {
                                  loginController.selectedCountryCode =
                                      country.dialCode ?? '+91';
                                  // Clear phone error when country changes
                                  if (_phoneError != null) {
                                    _phoneError = null;
                                  }
                                });
                                print('Selected country: ${country.name}');
                                print('Dial code: ${country.dialCode}');
                              },
                              initialSelection: 'IN',
                              favorite: const ['+91', '+1'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              textStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontFamily: 'Figtree-Regular',
                                fontWeight: FontWeight.w400,
                              ),
                              dialogTextStyle: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF101828),
                              ),
                              dialogBackgroundColor: Colors.white,
                              barrierColor: Colors.black54,
                              backgroundColor: Colors.white,
                              boxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              searchDecoration: InputDecoration(
                                hintText: 'Search country',
                                hintStyle: const TextStyle(
                                  color: Color(0x99183954),
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF667085),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E2E2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E2E2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppConfig.primaryColor,
                                  ),
                                ),
                              ),
                              searchStyle: const TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 14,
                              ),
                              dialogSize: Size(
                                MediaQuery.of(context).size.width * 0.85,
                                MediaQuery.of(context).size.height * 0.7,
                              ),
                              flagWidth: 20,
                              showFlagMain: false,
                              showFlagDialog: true,
                              showFlag: true,
                              showDropDownButton: false,
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: CustomTextField(
                              fieldHeight: 48,
                              controller: loginController.loginPhoneController,
                              focusNode: _phoneFocusNode,
                              hintText: 'Enter phone number',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              errorText: _phoneError,
                              onChanged: (value) {
                                // Clear error when user starts typing
                                if (_phoneError != null) {
                                  setState(() {
                                    _phoneError = null;
                                  });
                                }

                                if (value.length < 10) {
                                  _lastAutoSubmittedPhone = null;
                                  return;
                                }

                                if (!_isLoading &&
                                    value.length == 10 &&
                                    _lastAutoSubmittedPhone != value) {
                                  _lastAutoSubmittedPhone = value;
                                  _phoneFocusNode.unfocus();
                                  _validateAndSendOTP();
                                }
                              },
                              onSubmitted: (value) {
                                // Trigger validation when user presses Done
                                if (!_isLoading) {
                                  _validateAndSendOTP();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    // padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Send OTP button
                        CustomButton(
                          text: _isLoading ? "Sending..." : "Send OTP",
                          isLoading: _isLoading,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _isLoading ? null : _validateAndSendOTP,
                        ),

                        const SizedBox(height: 16),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF475467),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.40,
                              ),
                            ),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Get.toNamed(AppRoutes.signUpScreen);
                                    },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFE8943A),
                                        Color(0xFFE8943A),
                                      ],
                                    ).createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottomSheet: Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
          //   decoration: const BoxDecoration(color: Colors.white),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       // Send OTP button
          //       CustomButton(
          //         text: _isLoading ? "Sending..." : "Send OTP",
          //         contentPadding: const EdgeInsets.symmetric(vertical: 15),
          //         borderRadius: BorderRadius.circular(12),
          //         onPressed: _isLoading ? null : _validateAndSendOTP,
          //       ),
          //
          //       const SizedBox(height: 16),
          //
          //       // Sign up link
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Text(
          //             "Don't have Professional Account? ",
          //             style: TextStyle(
          //               color: Color(0xFF475467),
          //               fontSize: 14,
          //               fontWeight: FontWeight.w500,
          //               height: 1.40,
          //             ),
          //           ),
          //           TextButton(
          //             onPressed: _isLoading
          //                 ? null
          //                 : () {
          //                     Get.toNamed(AppRoutes.signUpScreen);
          //                   },
          //             style: TextButton.styleFrom(
          //               padding: EdgeInsets.zero,
          //               minimumSize: const Size(0, 0),
          //               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             ),
          //             child: ShaderMask(
          //               shaderCallback: (bounds) => const LinearGradient(
          //                 colors: [Color(0xFFE8943A), Color(0xFFE8943A)],
          //               ).createShader(bounds),
          //               blendMode: BlendMode.srcIn,
          //               child: Text(
          //                 'Sign up',
          //                 style: TextStyle(
          //                   color: _isLoading ? Colors.grey : Colors.white,
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w600,
          //                   height: 1.40,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
