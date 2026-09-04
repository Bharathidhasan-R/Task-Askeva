import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import '../../App Configuration/app_config.dart';
import '../../Controllers/Login_controller.dart';
import '../../Routes/app_routes.dart';
import '../../Web_view.dart';
import '../../common/Text Fields.dart';
import '../../common/button.dart';
import '../../common/export.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var loginController = Get.put(LoginController());
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isSubmitting = false;

  // Error text variables
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _termsError;

  // Terms and Conditions checkbox state
  bool _isTermsAccepted = true;

  // Validation Methods
  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    // Check if name contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name should contain only letters';
    }
    return null;
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or dashes
    String cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'Phone number should contain only digits';
    }

    // Validate length based on country code
    if (loginController.selectedCountryCode == '+91') {
      if (cleanPhone.length != 10) {
        return 'Phone number must be 10 digits';
      }
    }

    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email address is required';
    }

    // Email regex pattern
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validateTerms(bool isAccepted) {
    if (!isAccepted) {
      return 'You must accept the Terms and Conditions';
    }
    return null;
  }

  Future<void> _validateForm() async {
    if (_isSubmitting) return;

    setState(() {
      _nameError = _validateName(loginController.nameController.text.trim());
      _phoneError = _validatePhone(loginController.phoneController.text.trim());
      _emailError = _validateEmail(loginController.emailController.text.trim());
      _termsError = _validateTerms(_isTermsAccepted);
    });

    // If no errors, proceed with sign up
    if (_nameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _termsError == null) {
      final signUpPhone = loginController.phoneController.text.trim();

      setState(() {
        _isSubmitting = true;
      });

      // Call the API and wait for response
      try {
        await loginController.getSignUp("register", {
          "name": loginController.nameController.text.trim(),
          "ph_code": loginController.selectedCountryCode,
          "phone": signUpPhone,
          "email": loginController.emailController.text.trim(),
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }

      // Check if signup was successful after API completes
      if (loginController.signUpData.value["success"] == true) {
        _performSignUp(signUpPhone);
      }
    }
  }

  void _performSignUp(String phoneNumber) {
    // Clear any existing errors
    setState(() {
      _nameError = null;
      _phoneError = null;
      _emailError = null;
      _termsError = null;
    });

    // Navigate to OTP verification
    Get.toNamed(AppRoutes.oTPVerificationScreen,arguments: {
      "phone": phoneNumber,
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
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
                    const SizedBox(height: 40),

                    // Logo and Brand
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'services in a ',
                          style: TextStyle(
                            fontSize: 21,
                            fontFamily: 'Figtree-Medium',
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                        const Text(
                          'more streamlined ',
                          style: TextStyle(
                            fontSize: 21,
                            fontFamily: 'Figtree-Medium',
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE8943A),
                          ),
                        ),
                        const Text(
                          'way.',
                          style: TextStyle(
                            fontSize: 21,
                            fontFamily: 'Figtree-Medium',
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 50),

                    // Sign Up text
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF101828),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Name field
                    CustomTextField(
                      fieldHeight: 48,
                      controller: loginController.nameController,
                      hintText: 'Name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      errorText: _nameError,
                      onChanged: (value) {
                        // Clear error when user starts typing
                        if (_nameError != null) {
                          setState(() {
                            _nameError = null;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Phone number field with country code and validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Country Code Picker with custom styling
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:const Color(0xffE2E2E2),
                                  width: 1,
                                ),
                              ),
                              child: CountryCodePicker(
                                onChanged: (country) {
                                  setState(() {
                                    loginController.selectedCountryCode = country.dialCode ?? '+91';
                                    // Clear phone error when country changes
                                    if (_phoneError != null) {
                                      _phoneError = null;
                                    }
                                  });
                                  print('Selected country: ${country.name}');
                                  print('Dial code: ${country.dialCode}');
                                },
                                initialSelection: 'IN',
                                favorite: const ['+91', '+1',],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                enabled: false,
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                textStyle:TextStyle(
                                  color: const Color(0xFF98A2B3) /* color-grey-400 */,
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
                                  hintStyle: TextStyle(
                                    color: Color(0x99183954),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Color(0xFF667085),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE2E2E2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE2E2E2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
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
                                showDropDownButton: true,

                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: CustomTextField(
                                fieldHeight: 48,
                                controller: loginController.phoneController,
                                hintText: 'Phone number',
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.telephoneNumber],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                errorText: _phoneError,
                                onChanged: (value) {
                                  if (value.length == 10 && _phoneError == null) {
                                    _phoneFocusNode.unfocus();
                                    FocusScope.of(context).requestFocus(_emailFocusNode);
                                  }
                                  // Clear error when user starts typing
                                  if (_phoneError != null) {
                                    setState(() {
                                      _phoneError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Email field
                    CustomTextField(
                      fieldHeight: 48,
                      controller: loginController.emailController,
                      hintText: 'Email address',
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      errorText: _emailError,
                      onChanged: (value) {
                        // Clear error when user starts typing
                        if (_emailError != null) {
                          setState(() {
                            _emailError = null;
                          });
                        }
                      },
                      onSubmitted: (value) {
                        // Trigger validation when user presses Done
                        _validateForm();
                      },
                    ),

                    // const SizedBox(height: 30),
                    //
                    // // Terms and Conditions Checkbox
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     Row(
                    //
                    //       children: [
                    //         SizedBox(
                    //           width: 20,
                    //           height: 20,
                    //           child: Checkbox(
                    //             value: _isTermsAccepted,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 _isTermsAccepted = value ?? false;
                    //                 // Clear error when user checks the box
                    //                 if (_termsError != null) {
                    //                   _termsError = null;
                    //                 }
                    //               });
                    //             },
                    //             activeColor: AppConfig.secondaryColor,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(4),
                    //             ),
                    //             side: BorderSide(
                    //               color: _termsError != null
                    //                   ? Colors.red
                    //                   : const Color(0xFFD0D5DD),
                    //               width: 1.5,
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 12),
                    //         Expanded(
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               setState(() {
                    //                 _isTermsAccepted = !_isTermsAccepted;
                    //                 // Clear error when user checks the box
                    //                 if (_termsError != null) {
                    //                   _termsError = null;
                    //                 }
                    //               });
                    //             },
                    //             child:  RichText(
                    //               text: TextSpan(
                    //                 style: const TextStyle(
                    //                   fontSize: 14,
                    //                   fontFamily: 'Figtree-Regular',
                    //                   fontWeight: FontWeight.w400,
                    //                   height: 1.4,
                    //                   color: Color(0xFF475467),
                    //                 ),
                    //                 children: [
                    //                   const TextSpan(text: 'I agree to the '),
                    //                   WidgetSpan(
                    //                     alignment: PlaceholderAlignment.baseline,
                    //                     baseline: TextBaseline.alphabetic,
                    //                     child: GestureDetector(
                    //                       onTap: () {
                    //                         print('Navigate to Terms and Conditions');
                    //                       },
                    //                       child: const Text(
                    //                         'Terms & Conditions',
                    //                         style: TextStyle(
                    //                           fontSize: 14,
                    //                           fontFamily: 'Figtree-Medium',
                    //                           fontWeight: FontWeight.w500,
                    //                           color: Color(0xFF1D60FF),
                    //                           height: 1.4,
                    //                           decoration: TextDecoration.underline,
                    //                           decorationColor: Color(0xFF1D60FF),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   const TextSpan(text: ' of '),
                    //                   const TextSpan(
                    //                     text: 'Vayil',
                    //                     style: TextStyle(
                    //                       color: Color(0xFFE8943A),
                    //                       fontSize: 14,
                    //                       fontFamily: 'Figtree-Medium',
                    //                       fontWeight: FontWeight.w700,
                    //                       height: 1.4,
                    //                     ),
                    //                   ),
                    //                   const TextSpan(text: '.'),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     if (_termsError != null)
                    //       Padding(
                    //         padding: const EdgeInsets.only(left: 0, top: 8),
                    //         child: Text(
                    //           _termsError!,
                    //           style: const TextStyle(
                    //             fontSize: 12,
                    //             color: Colors.red,
                    //             fontFamily: 'Figtree-Regular',
                    //           ),
                    //         ),
                    //       ),
                    //   ],
                    // ),

                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sign up button
                          CustomButton(
                            text: _isSubmitting ? "Sending..." : "Sign up",
                            isLoading: _isSubmitting,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _isSubmitting ? null : _validateForm,
                          ),

                          // const SizedBox(height: 20),
                          //
                          // // Sign up with Google button
                          // Container(
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(
                          //       color: const Color(0xFFD0D5DD),
                          //       width: 1,
                          //     ),
                          //   ),
                          //   child: TextButton(
                          //     onPressed: () {},
                          //     style: TextButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(vertical: 12),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Image.network(
                          //           'https://www.google.com/favicon.ico',
                          //           width: 20,
                          //           height: 20,
                          //         ),
                          //         const SizedBox(width: 12),
                          //         const Text(
                          //           'Sign up with Google',
                          //           style: TextStyle(
                          //             color: const Color(0xFF183954),
                          //             fontSize: 16,
                          //             fontWeight: FontWeight.w600,
                          //             height: 1.40,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(height: 20),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: const Color(0xFF475467),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.40,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      Color(0xFFE8943A),
                                      Color(0xFFE8943A),
                                    ],
                                  ).createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'By clicking on signup, you agree to the ',
                                  style: TextStyle(
                                    color: const Color(0xFF637381),
                                    fontSize: 14,
                                    fontFamily: 'Figtree-Medium',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WebViewScreen(
                                              title: 'Terms & Conditions',
                                              url: 'https://app.vayil.in/customer-terms-conditions',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('Terms & Conditions',style: TextStyle(
                                        color: const Color(0xFF1D60FF),
                                        fontSize: 14,
                                        fontFamily: 'Figtree-Medium',
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF1D60FF),
                                      ),),)


                                ),
                                TextSpan(
                                  text: ' of ',
                                  style: TextStyle(
                                    color: const Color(0xFF637381),
                                    fontSize: 14,
                                    fontFamily: 'Figtree-Medium',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Vayil',
                                  style: TextStyle(
                                    color: const Color(0xFFE8943A),
                                    fontSize: 14,
                                    fontFamily: 'Figtree-Medium',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(
                                    color: const Color(0xFF637381),
                                    fontSize: 14,
                                    fontFamily: 'Figtree-Medium',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
