import 'dart:math' as math;

import 'package:flutter/material.dart';

class Transitioner extends StatelessWidget {
  final Animation animation;
  final Widget child1;
  final Widget child2;
  final Curve curve;

  Transitioner({
    @required this.animation,
    @required this.child1,
    @required this.child2,
    this.curve = Curves.easeInOut,
  })  : assert(animation != null),
        assert(child1 != null),
        assert(child2 != null);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        double value = animation.value;
        value = curve.transform(value);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(((0.5 - value).abs() * 2 - 1) * math.pi / 2),
          child: value <= 0.5 ? child1 : child2,
        );
      },
    );
  }
}
