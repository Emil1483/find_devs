import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;

  const MainButton({
    @required this.onPressed,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return RaisedButton(
      color: theme.accentColor,
      textColor: theme.canvasColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
