import 'package:flutter/material.dart';

class AccountRoute extends StatefulWidget {
  static const String routeName = "/account";

  @override
  _AccountRouteState createState() => _AccountRouteState();
}

class _AccountRouteState extends State<AccountRoute> {
  bool _dev = false;
  bool _work = false;
  bool _collab = false;
  bool _hideFromMaps = false;

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
          onTap: () => _dev = !_dev,
          text: "Looking for developers",
          value: _dev,
        ),
        _buildListTile(
          icon: Icon(Icons.work),
          onTap: () => _work = !_work,
          text: "Looking for work",
          value: _work,
        ),
        _buildListTile(
          icon: Icon(Icons.code),
          onTap: () => _collab = !_collab,
          text: "Looking to collaborate",
          value: _collab,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            labelText: "Username",
            icon: Icon(Icons.person),
          ),
        ),
        TextFormField(
          maxLines: 5,
          decoration: InputDecoration(
            labelText: "About you",
            alignLabelWithHint: true,
            icon: Icon(Icons.description),
          ),
        ),
        TextFormField(
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
        onPressed: () {},
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
    return Container(
      height: 36,
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          setState(() => _hideFromMaps = !_hideFromMaps);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Hide from maps"),
            Switch(
              onChanged: (bool value) => setState(() => _hideFromMaps = value),
              value: _hideFromMaps,
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
