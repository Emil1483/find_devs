import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;

  GradientButton({
    @required this.onPressed,
    @required this.child,
    @required this.gradient,
    this.padding = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
  })  : assert(child != null),
        assert(gradient != null);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.0),
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Theme.of(context).indicatorColor,
            onTap: onPressed,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
