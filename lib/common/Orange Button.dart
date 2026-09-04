import 'export.dart';

class VayilOrangeButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double? height;

  const VayilOrangeButton({
    super.key,
    required this.title,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height ?? 46,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8943A),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C101828),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Figtree-Medium',
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}