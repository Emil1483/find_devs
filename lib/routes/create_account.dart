import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import './home_route.dart';

class CreateAccountRoute extends StatefulWidget {
  static const String routeName = "/createAcc";

  @override
  _CreateAccountRouteState createState() => _CreateAccountRouteState();
}

class _CreateAccountRouteState extends State<CreateAccountRoute> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _passwordConfirm;

  Widget _buildLogo() {
    return Container(
      alignment: Alignment.center,
      height: 177.0,
      margin: EdgeInsets.symmetric(vertical: 22.0),
      child: Image(
        image: AssetImage("assets/missing_asset.png"),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return <Widget>[
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        onSaved: (String str) => _email = str,
        decoration: InputDecoration(
          labelText: "Email",
          icon: Icon(Icons.mail),
        ),
        validator: (String input) {
          if (input.isEmpty) return "Please type in your email";
          if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
          ).hasMatch(input)) return "Email must be valid";

          return null;
        },
      ),
      TextFormField(
        obscureText: true,
        onFieldSubmitted: (String str) => _password = str,
        decoration: InputDecoration(
          labelText: "Password",
          icon: Icon(Icons.lock),
        ),
        validator: (String input) {
          if (input.isEmpty) return "Please type in your password";
          if (input.length < 6) return "Password must be 6 characters or more";

          return null;
        },
      ),
      TextFormField(
        obscureText: true,
        onSaved: (String str) => _passwordConfirm = str,
        decoration: InputDecoration(
          labelText: "Confirm Password",
          icon: Icon(Icons.lock),
        ),
        validator: (String input) {
          if (_password.isEmpty) return null;
          if (_password.length < 6) return null;
          if (input != _password) return "Passwords does not match";

          return null;
        },
      ),
    ];
  }

  Widget _buildContinue() {
    User user = Provider.of<User>(context, listen: false);
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text("Continue"),
      onPressed: () async {
        final formState = _formKey.currentState;
        formState.save();
        if (!formState.validate()) return;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create your Account"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildLogo(),
                ..._buildFormFields(),
                SizedBox(height: 22.0),
                _buildContinue(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
