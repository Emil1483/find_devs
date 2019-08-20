import 'dart:math' as math;

import 'package:flutter/material.dart';

class Shrink extends StatefulWidget {
  final Widget child;
  final Animation animation;
  final bool reverse;

  const Shrink({
    @required this.child,
    @required this.animation,
    this.reverse = false,
    Key key,
  }) : super(key: key);

  @override
  ShrinkState createState() => ShrinkState();
}

class ShrinkState extends State<Shrink> {
  double _height;

  void setHeight(double h) => setState(() => _height = h);

  @override
  Widget build(BuildContext context) {
    double h;
    if (_height == null)
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          h = context.size.height;
        },
      );
    else
      h = _height;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, _) {
        double value = Curves.easeInOut.transform(widget.animation.value);
        if (widget.reverse) value = 1 - value;
        return Container(
          constraints: BoxConstraints.tightFor(
            height: h != null ? h * (1 - value) : null,
          ),
          child: Transform(
            transform: Matrix4.identity()..rotateX(value * math.pi / 2),
            alignment: Alignment.center,
            child: widget.child,
          ),
        );
      },
    );
  }
}
