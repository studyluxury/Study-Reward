import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const CardShell({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 16),
            color: Colors.black.withValues(alpha: 0.08),
          )
        ],
      ),
      child: child,
    );
  }
}
