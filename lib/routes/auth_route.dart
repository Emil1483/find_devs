import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import './home_route.dart';
import './create_account.dart';

class AuthRoute extends StatefulWidget {
  static const routeName = "/auth";

  @override
  _AuthRouteState createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

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
    ];
  }

  Widget _buildLogin(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text("Login"),
      onPressed: () async {
        final formState = _formKey.currentState;
        if (!formState.validate()) return;
        formState.save();

        if (await user.signInWithEmail(
          email: _email,
          password: _password,
        )) {
          Navigator.pushReplacementNamed(context, HomeRoute.routeName);
        }
      },
    );
  }

  Widget _buildGoogleLogin() {
    return RaisedButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: () {},
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
    );
  }

  Widget _buildCreateAcc(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Feedback.forLongPress(context);
          Navigator.pushNamed(context, CreateAccountRoute.routeName);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Text(
            "Create an Account",
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
                _buildCreateAcc(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
