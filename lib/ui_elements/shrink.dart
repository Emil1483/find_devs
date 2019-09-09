import 'dart:math' as math;

import 'package:flutter/material.dart';

class Shrink extends StatefulWidget {
  final Widget child;
  final Animation animation;

  const Shrink({
    @required this.child,
    @required this.animation,
    Key key,
  }) : super(key: key);

  @override
  ShrinkState createState() => ShrinkState();
}

class ShrinkState extends State<Shrink> {
  double height;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        height = context.size.height;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, _) {
        double value = Curves.easeInOut.transform(widget.animation.value);
        double h;
        if (height != null) {
          h = height * (1 - value);
        } else {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() {}),
          );
        }
        return Container(
          constraints: BoxConstraints.tightFor(
            height: h,
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
