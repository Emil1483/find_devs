import 'package:flutter/material.dart';

class CreateAccountRoute extends StatelessWidget {
  static const String routeName = "/createAcc";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create an Account"),
      ),
    );
  }
}
