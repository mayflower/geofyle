import 'package:flutter/material.dart';

class AnimatedScreenTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginOpacity;
  final double endOpacity;
  final Curve curve;
  final Curve opacityCurve;

  const AnimatedScreenTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.beginOffset = const Offset(0, 0.2),
    this.endOffset = Offset.zero,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.curve = Curves.easeOut,
    this.opacityCurve = Curves.easeIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: beginOpacity, end: endOpacity).animate(
            CurvedAnimation(
              parent: animation,
              curve: Interval(0.0, 0.6, curve: opacityCurve),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: endOffset,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Interval(0.0, 0.6, curve: curve),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}