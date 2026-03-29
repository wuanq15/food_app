import 'package:flutter/material.dart';

class RoundIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;
  final String icon; // asset path
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final bool isDisabled;

  const RoundIconButton({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.isDisabled = false,
  });

  @override
  State<RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<RoundIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDisabled
        ? Colors.grey.shade300
        : widget.backgroundColor;

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.isDisabled ? null : widget.onPressed,
          onHighlightChanged: (v) {
            setState(() => _pressed = v);
          },
          splashColor: Colors.white.withValues(alpha: 0.25),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: widget.isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(widget.icon, width: 25, height: 25),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
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
