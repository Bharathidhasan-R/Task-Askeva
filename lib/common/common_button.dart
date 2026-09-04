import 'export.dart'
    show
        StatelessWidget,
        VoidCallback,
        BuildContext,
        Widget,
        EdgeInsets,
        Color,
        BorderSide,
        TextStyle,
        BorderRadius,
        RoundedRectangleBorder,
        ShapeDecoration,
        Clip,
        Offset,
        BoxShadow,
        TextAlign,
        Colors,
        FontWeight,
        Text,
        Container,
        GestureDetector;

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color? color;
  final Color? text;

  const PrimaryButton({
    super.key,
    required this.title,
    this.onTap,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: color ?? const Color(0xFF1A202C),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: color ?? const Color(0xFF1A202C),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C101828),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text ?? Colors.white,
              fontSize: 16,
              fontFamily: 'Figtree-Medium',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
