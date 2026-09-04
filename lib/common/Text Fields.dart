import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../App Configuration/app_config.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted; // NEW: Called when user presses Done/Enter
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final double fontSize;
  final double borderRadius;
  final double fieldHeight;
  final TextInputAction textInputAction; // NEW: Control keyboard action button
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.fontSize = 15,
    this.borderRadius = 12,
    this.fieldHeight = 56,
    this.textInputAction = TextInputAction.done, // default: Done
    this.focusNode,
    this.autofillHints,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.fieldHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // boxShadow: hasError
            //     ? [
            //   BoxShadow(
            //     color: Colors.red.withOpacity(0.1),
            //     blurRadius: 8,
            //     offset: const Offset(0, 2),
            //   )
            // ]
            //     : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction, // Next / Done / Search etc.
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted, // This is what you wanted!
            onEditingComplete: widget.onEditingComplete,
            maxLines: widget.maxLines,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: Colors.black87,
              // color: const Color(0xFF98A2B3),
              fontWeight: FontWeight.w400,
              fontFamily: 'Figtree-Regular',
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: const Color(0x99183954),
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon ??
                  (widget.obscureText
                      ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF98A2B3),
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                      : null),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: _border(widget.borderRadius),
              enabledBorder: _border(widget.borderRadius),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppConfig.primaryColor,
                  width: hasError ? 1 : 1,
                ),
              ),
              errorBorder: _border(widget.borderRadius, color: Colors.red),
              focusedErrorBorder: _border(widget.borderRadius, color: Colors.red, width: 2),
            ),
          ),
        ),

        // Error Text Below Field
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Figtree-Regular',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // Reusable border to avoid duplication
  OutlineInputBorder _border(double radius, {Color color = const Color(0xffE2E2E2), double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class Common {



  TextStyle fieldTextStyle({double size=14}) {
    return  TextStyle(
      color: AppConfig.primaryColor,
      fontSize: size,
      fontWeight: FontWeight.w900,
      fontFamily: 'Figtree-Medium',
      height: 1.43,
    );
  }

  TextStyle buttonTextStyle1() {
    return TextStyle(
      fontSize: 18,
      color: AppConfig.primaryColor,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
    );
  }

  Widget buildInputField(String hintText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.grey[500]),
      decoration:  InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        labelStyle: const TextStyle(color: Color(0xff4B5563)),
        hintText: hintText,
        border: InputBorder.none,
      ),
    );

  }

  Widget card(Widget card) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: card,
    );
  }
}

// // 1. Email / Phone / Username Field
// CustomTextField(
// controller: _emailController,
// hintText: 'Email or phone or username',
// keyboardType: TextInputType.emailAddress,
// ),
//
// // 2. Password Field (with eye icon)
// CustomTextField(
// controller: _passwordController,
// hintText: 'Password',
// obscureText: true,
// ),
//
// // 3. With Error
// CustomTextField(
// controller: _emailController,
// hintText: 'Email',
// errorText: 'Please enter a valid email',
// ),
//
// // 4. With Prefix Icon
// CustomTextField(
// controller: _searchController,
// hintText: 'Search',
// prefixIcon: const Icon(Icons.search, color: Color(0xff98A2B3)),
// ),

Common common = Common();
