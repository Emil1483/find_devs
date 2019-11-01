import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';

import './home_route.dart';
import '../providers/user.dart';
import '../providers/devs.dart';
import '../ui_elements/alert_dialog.dart';
import '../ui_elements/button.dart';

class AccountRoute extends StatefulWidget {
  static const String routeName = "/account";

  @override
  _AccountRouteState createState() => _AccountRouteState();
}

class _AccountRouteState extends State<AccountRoute> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UserData _userData;
  TextEditingController _username;
  TextEditingController _about;
  TextEditingController _city;
  bool _edited = false;
  bool _loading = true;
  bool _error = false;
  bool _saving = false;

  @override
  initState() {
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    super.dispose();
    if (_username != null) _username.dispose();
    if (_about != null) _about.dispose();
    if (_city != null) _city.dispose();
  }

  void _update() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<bool> _getUser() async {
    final User user = Provider.of<User>(context, listen: false);

    _userData = await user.getUserData();
    if (_userData == null) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return false;
    }

    _edited = !Navigator.of(context).canPop();

    final onChanged = () => setState(() => _edited = true);
    _username = TextEditingController(text: _userData.username)
      ..addListener(onChanged);
    _about = TextEditingController(text: _userData.about)
      ..addListener(onChanged);
    _city = TextEditingController(text: _userData.city)..addListener(onChanged);

    setState(() => _loading = false);
    return true;
  }

  Widget _buildListTile({
    @required Function onTap,
    @required String text,
    @required Widget icon,
    @required bool value,
  }) {
    return ListTile(
      onTap: () => setState(onTap),
      title: Text(text),
      leading: icon,
      trailing: Checkbox(
        onChanged: (bool value) => setState(onTap),
        value: value,
      ),
    );
  }

  Widget _buildLoadingText(String text, bool loading) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (loading)
          Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).canvasColor,
              strokeWidth: 2.5,
            ),
          ),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: !loading,
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildSwitch(Function onChange, String text, bool value) {
    Function onTap = () {
      setState(() {
        onChange();
        _edited = true;
      });
    };
    return Container(
      height: 36,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(text),
            Switch(
              onChanged: (bool value) => onTap(),
              value: value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildLookingFor() {
    return Column(
      children: <Widget>[
        _buildListTile(
          icon: Icon(Icons.person),
          onTap: () {
            _userData.lookForDevs = !_userData.lookForDevs;
            setState(() => _edited = true);
          },
          text: "Looking for developers",
          value: _userData.lookForDevs,
        ),
        _buildListTile(
          icon: Icon(Icons.work),
          onTap: () {
            _userData.lookForWork = !_userData.lookForWork;
            setState(() => _edited = true);
          },
          text: "Looking for work",
          value: _userData.lookForWork,
        ),
        _buildListTile(
          icon: Icon(Icons.code),
          onTap: () {
            _userData.lookToCollab = !_userData.lookToCollab;
            setState(() => _edited = true);
          },
          text: "Looking to collaborate",
          value: _userData.lookToCollab,
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      alignment: Alignment.center,
      height: 222.0,
      margin: EdgeInsets.only(bottom: 12.0),
      child: Image(
        image: AssetImage("assets/account.png"),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _username,
          onSaved: (String val) {
            _userData.username = val.trim();
          },
          decoration: InputDecoration(
            labelText: "Username",
            icon: Icon(Icons.person),
          ),
          validator: (String val) {
            if (val == null || val.isEmpty || val == " " * val.length) {
              return "Please choose a username";
            }
            return null;
          },
        ),
        TextFormField(
          maxLines: 5,
          controller: _about,
          onSaved: (String val) {
            _userData.about = val.trim();
          },
          maxLength: 300,
          decoration: InputDecoration(
            labelText: "About you",
            alignLabelWithHint: true,
            icon: Icon(Icons.description),
          ),
        ),
        TextFormField(
          controller: _city,
          decoration: InputDecoration(
            labelText: "City/state",
            icon: Icon(Icons.location_city),
          ),
          onSaved: (String val) {
            _userData.city = val.trim();
          },
          validator: (String value) {
            if (!_userData.hideCity && value.isEmpty)
              return "Please type your city";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmail(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    String email;
    if (user.user != null)
      email = user.user.email;
    else {
      email = "Could not get email";
      _update();
    }
    return TextField(
      controller: TextEditingController(text: email),
      enabled: false,
      style: TextStyle(color: Theme.of(context).disabledColor),
      decoration: InputDecoration(
        labelText: "Email",
        icon: Icon(Icons.email),
      ),
    );
  }

  Widget _buildSave() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: MainButton(
        child: _buildLoadingText("Save", _saving),
        onPressed: _edited
            ? () async {
                if (!_formKey.currentState.validate()) return;
                _formKey.currentState.save();

                setState(() => _saving = true);

                final User user = Provider.of<User>(context, listen: false);

                Address address = await user.getCityFromQuery(_userData.city);

                if (address == null) {
                  showAlertDialog(
                    context,
                    title: "Could not find your city",
                    content: "Please try another",
                  );
                  setState(() => _saving = false);
                  return;
                }

                String city = user.getCityFromAddress(address);

                _userData.city = city;
                setState(() => _city.text = _userData.city);

                Provider.of<Devs>(context).init(
                  coordinates: address.coordinates,
                );

                final bool result = await user.updateUserData(_userData);
                if (!result) {
                  showAlertDialog(
                    context,
                    title: "Could not save data",
                    content: "Please try again",
                  );
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(HomeRoute.routeName);
                }

                setState(() => _saving = false);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      bool back = Navigator.of(context).canPop();
      TextTheme theme = Theme.of(context).textTheme;
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildLogo(),
                Text("Oops!", style: theme.display2),
                SizedBox(height: 12),
                Text("Could not load your settings", style: theme.headline),
                SizedBox(height: 8),
                Text(
                  "Check your internet",
                  style: theme.body1,
                ),
                SizedBox(height: 16),
                MainButton(
                  onPressed: () async {
                    if (back)
                      Navigator.pop(context);
                    else {
                      setState(() => _loading = true);
                      await Future.delayed(Duration(milliseconds: 400));
                      if (await _getUser()) {
                        setState(() {
                          _loading = false;
                          _error = false;
                        });
                      } else
                        setState(() => _loading = false);
                    }
                  },
                  child: _buildLoadingText(
                      back ? "Back to Homepage" : "Try Again", _loading),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_loading)
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          children: <Widget>[
            _buildLogo(),
            _text("Why did you get this app?"),
            _buildLookingFor(),
            _text("Tell me about yourself"),
            _buildFormFields(),
            _buildSwitch(
              () => _userData.hideCity = !_userData.hideCity,
              "Hide city from others",
              _userData.hideCity,
            ),
            _buildEmail(context),
            _buildSwitch(
              () => _userData.hideEmail = !_userData.hideEmail,
              "Hide email from others",
              _userData.hideEmail,
            ),
            _buildSave(),
          ],
        ),
      ),
    );
  }
}
