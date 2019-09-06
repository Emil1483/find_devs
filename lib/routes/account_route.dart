import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../ui_elements/alert_dialog.dart';

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

  @override
  initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    super.dispose();
    _username.dispose();
    _about.dispose();
    _city.dispose();
  }

  void getUser() async {
    final User user = Provider.of<User>(context, listen: false);

    _userData = await user.getUserData();

    final onChanged = () => setState(() => _edited = true);
    _username = TextEditingController(text: _userData.username)
      ..addListener(onChanged);
    _about = TextEditingController(text: _userData.about)
      ..addListener(onChanged);
    _city = TextEditingController(text: _userData.city)..addListener(onChanged);

    setState(() => _loading = false);
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
          onSaved: (String val) {
            _userData.city = val.trim();
          },
          decoration: InputDecoration(
            labelText: "City",
            icon: Icon(Icons.location_city),
          ),
        ),
      ],
    );
  }

  Widget _buildSave() {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        color: theme.accentColor,
        textColor: theme.canvasColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: _edited
            ? () async {
                if (!_formKey.currentState.validate()) return;
                _formKey.currentState.save();
                final User user = Provider.of<User>(context, listen: false);
                final bool result = await user.updateUserData(_userData);
                if (!result) {
                  showAlertDialog(
                    context,
                    title: "Could not save data",
                    content: "Please try again",
                  );
                } else {
                  setState(() => _edited = false);
                }
              }
            : null,
        child: Text("Save"),
      ),
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

  Widget _buildHide() {
    Function onTap = () {
      setState(() {
        _userData.hideFromMaps = !_userData.hideFromMaps;
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
            Text("Hide from maps"),
            Switch(
              onChanged: (bool value) => onTap(),
              value: _userData.hideFromMaps,
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

  @override
  Widget build(BuildContext context) {
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
            _buildHide(),
            _buildSave(),
          ],
        ),
      ),
    );
  }
}
