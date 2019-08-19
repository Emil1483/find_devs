import 'package:flutter/material.dart';

class AuthRoute extends StatelessWidget {
  static const routeName = "/auth";

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
        decoration: InputDecoration(
          labelText: "Email",
          icon: Icon(Icons.mail),
        ),
        validator: (String input) {
          if (input.isEmpty) return "Please type email";
          return null;
        },
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: "Password",
          icon: Icon(Icons.lock),
        ),
        validator: (String input) {
          if (input.isEmpty) return "Please type email";
          return null;
        },
        obscureText: true,
      ),
    ];
  }

  Widget _buildLogin() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text("Login"),
      onPressed: () {},
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
        },
        child: Padding(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildLogo(),
                ..._buildFormFields(),
                SizedBox(height: 22.0),
                _buildLogin(),
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
