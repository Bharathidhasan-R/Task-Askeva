import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_safe_area.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget? leading;
  final Widget? trailing;
  final Color backgroundColor;
  final double height;

  const CustomAppBar({
    super.key,
    this.title,
    this.onBackPressed,
    this.showBackButton = true,
    this.leading,
    this.trailing,
    this.backgroundColor = const Color(0xFF183954),
    this.height = 73,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leading Widget (Back button or custom widget)
                leading ??
                    (showBackButton
                        ? GestureDetector(
                      onTap: onBackPressed ??
                              () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white.withOpacity(0.20),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x33D9D9D9),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                        : const SizedBox.shrink()),

                // Center Title Widget
                if (title != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x2DD9D9D9),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      title!,
                      style:TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Figtree-Medium",
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Trailing Widget (Spacer or custom widget)
                trailing ?? const SizedBox(width: 52),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage variations:

// 1. Basic usage with title
class Example1 extends StatelessWidget {
  const Example1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ABC Constructions',
      ),
      body: Container(),
    );
  }
}

// 2. Custom back action
class Example2 extends StatelessWidget {
  const Example2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ABC Constructions',
        onBackPressed: () {
          // Custom back logic
          print('Custom back pressed');
          Navigator.of(context).pop();
        },
      ),
      body: Container(),
    );
  }
}

// 3. Without back button
class Example3 extends StatelessWidget {
  const Example3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ABC Constructions',
        showBackButton: false,
      ),
      body: Container(),
    );
  }
}

// 4. Custom leading widget
class Example4 extends StatelessWidget {
  const Example4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ABC Constructions',
        leading: GestureDetector(
          onTap: () {
            // Custom action
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x33D9D9D9)),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: Container(),
    );
  }
}

// 5. Custom trailing widget (action buttons)
class Example5 extends StatelessWidget {
  const Example5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ABC Constructions',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // Search action
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0x33D9D9D9)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Notifications action
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0x33D9D9D9)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
      body: Container(),
    );
  }
}

// 6. Different background color
class Example6 extends StatelessWidget {
  const Example6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ABC Constructions',
        backgroundColor: Color(0xFF2C5F2D),
      ),
      body: Container(),
    );
  }
}

// 7. No title, custom widgets on both sides
class Example7 extends StatelessWidget {
  const Example7({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x33D9D9D9)),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ShapeDecoration(
            color: Colors.white.withOpacity(0.20),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x33D9D9D9)),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Container(),
    );
  }
}

// 8. Your original PlanListScreen with the dynamic appbar
class PlanListScreen extends StatelessWidget {
  const PlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      backgroundColor: const Color(0xFFF7FAFC),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        appBar: const CustomAppBar(
          title: 'ABC Constructions',
        ),
        body: Container(
          // Your body content here
        ),
      ),
    );
  }
}
