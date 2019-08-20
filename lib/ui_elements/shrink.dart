import 'dart:math' as math;

import 'package:flutter/material.dart';

class Shrink extends StatelessWidget {
  final Widget child;
  final Animation animation;

  const Shrink({
    @required this.child,
    @required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    double height;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        height = context.size.height;
      },
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        final double value = animation.value;
        return Container(
          constraints: BoxConstraints.tightFor(
            height: height != null ? height * (1 - value) : null,
          ),
          child: Transform(
            transform: Matrix4.identity()..rotateX(value * math.pi / 2),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}
