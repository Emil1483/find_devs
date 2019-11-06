import 'package:flutter/material.dart';

import '../ui_elements/button.dart';

class ErrorRoute extends StatelessWidget {
  final String errorMessage;
  final Function(BuildContext context) buttonOnPressed;
  final Widget buttonChild;

  const ErrorRoute({
    @required this.errorMessage,
    @required this.buttonOnPressed,
    @required this.buttonChild,
  });

  Widget _buildLogo(double height) {
    return Container(
      alignment: Alignment.center,
      height: height,
      child: Image(
        image: AssetImage("assets/broken.png"),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Text("Oops!", style: theme.display2),
        SizedBox(height: 12),
        Text(errorMessage, style: theme.headline),
        SizedBox(height: 8),
        Text(
          "Check your internet",
          style: theme.body1,
        ),
        SizedBox(height: 16),
        MainButton(
          onPressed: () => buttonOnPressed(context),
          child: buttonChild,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: portrait
              ? Column(
                  children: <Widget>[
                    _buildLogo(222),
                    _buildMain(context),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildLogo(322),
                    ),
                    Expanded(
                      child: _buildMain(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
