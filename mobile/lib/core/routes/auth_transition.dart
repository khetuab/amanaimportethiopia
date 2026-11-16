import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Fade + slide + subtle scale between screens.
class AuthTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final a = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .05), end: Offset.zero).animate(a),
        child: ScaleTransition(
          scale: Tween<double>(begin: .98, end: 1).animate(a),
          child: child,
        ),
      ),
    );
  }
}