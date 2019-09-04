import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import './home_route.dart';
import '../ui_elements/shrink.dart';
import '../ui_elements/transitioner.dart';
import '../ui_elements/alert_dialog.dart';

class AuthRoute extends StatefulWidget {
  static const routeName = "/auth";

  @override
  _AuthRouteState createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  AnimationController _controller;

  bool get _login => _controller.value < 0.5;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

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
        onSaved: (String str) => _password = str,
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
      SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-1.2, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOutCubic,
          ),
        ),
        child: TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            icon: Icon(Icons.lock),
          ),
          validator: (String input) {
            if (_login) return null;
            if (_password.isEmpty) return null;
            if (_password.length < 6) return null;
            if (input != _password) return "Passwords does not match";

            return null;
          },
        ),
      ),
    ];
  }

  Widget _buildLogin(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    ThemeData theme = Theme.of(context);

    return RaisedButton(
      color: theme.accentColor,
      textColor: theme.canvasColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Transitioner(
        animation: _controller,
        child1: Text("Login"),
        child2: Text("Continue"),
      ),
      onPressed: () async {
        final formState = _formKey.currentState;
        formState.save();
        if (!formState.validate()) return;

        AuthError error;
        if (_login) {
          error = await user.signInWithEmail(
            email: _email,
            password: _password,
          );
        } else {
          error = await user.signUp(
            email: _email,
            password: _password,
          );
        }

        if (error == null) {
          Navigator.pushReplacementNamed(context, HomeRoute.routeName);
        } else {
          showAlertDialog(
            context,
            title: _login ? "Could not login" : "Could not create account",
            content: getErrorMessage(error),
          );
        }
      },
    );
  }

  Widget _buildGoogleLogin() {
    User user = Provider.of<User>(context, listen: false);
    return Shrink(
      animation: _controller,
      child: Container(
        height: 38,
        child: RaisedButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () async {
            AuthError error = await user.googleSignIn();
            if (error == null) {
              Navigator.pushReplacementNamed(context, HomeRoute.routeName);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/google_logo.png",
                width: 22.0,
              ),
              SizedBox(width: 8.0),
              Text(
                "Sign in with Google",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtomFull(BuildContext context) {
    return Transitioner(
      animation: _controller,
      child1: _buildButtom(
        context,
        "Create an Account",
        () {
          Feedback.forLongPress(context);
          _controller.forward();
        },
      ),
      child2: _buildButtom(
        context,
        "Login Using Existing Account",
        () {
          Feedback.forLongPress(context);
          _controller.reverse();
        },
      ),
    );
  }

  Widget _buildButtom(BuildContext context, String text, Function onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: Theme.of(context).textTheme.title,
        ),
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
                _buildLogin(context),
                _buildGoogleLogin(),
                _buildButtomFull(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
