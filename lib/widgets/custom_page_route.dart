import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool forwardAnimation;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.forwardAnimation = true,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return child;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final begin =
                forwardAnimation ? Offset(1.0, 0.0) : Offset(-1.0, 0.0);
            final end = Offset.zero;

            final tween = Tween<Offset>(
              begin: begin,
              end: end,
            );

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.ease,
              reverseCurve: Curves.easeOutBack,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: duration,
        );
}
