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

  void getUser() async {
    final User user = Provider.of<User>(context, listen: false);
    try {
      _userData = await user.getUserData();
      _username = TextEditingController(text: _userData.username);
      _about = TextEditingController(text: _userData.about);
      _city = TextEditingController(text: _userData.city);
    } catch (e) {
      _userData = UserData();
      print("could not get user data: $e");
    }
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
        TextField(
          controller: _username,
          onChanged: (String val) {
            _userData.username = val;
            setState(() => _edited = true);
          },
          decoration: InputDecoration(
            labelText: "Username",
            icon: Icon(Icons.person),
          ),
        ),
        TextField(
          maxLines: 5,
          controller: _about,
          onChanged: (String val) {
            _userData.about = val;
            setState(() => _edited = true);
          },
          decoration: InputDecoration(
            labelText: "About you",
            alignLabelWithHint: true,
            icon: Icon(Icons.description),
          ),
        ),
        TextField(
          controller: _city,
          onChanged: (String val) {
            _userData.city = val;
            setState(() => _edited = true);
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
      body: ListView(
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
    );
  }
}
