import 'package:flutter/material.dart';

import '../providers/user.dart';

class UserTile extends StatelessWidget {
  final UserData userData;

  UserTile({@required this.userData});

  Widget _buildMain(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: userData.imageUrl == null || userData.imageUrl.isEmpty
              ? Center(
                  child: Icon(Icons.person, size: 36.0),
                )
              : Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userData.imageUrl),
                    radius: 22,
                  ),
                ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(userData.username),
              SizedBox(height: 6.0),
              Text(userData.about, maxLines: 5, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheck(BuildContext context,
      {bool checked, IconData icon, String text}) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: checked
                ? Theme.of(context).accentColor
                : Theme.of(context).disabledColor,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCheck(
              context,
              checked: userData.lookToCollab,
              icon: Icons.code,
              text: "Looking to Collaborate",
            ),
            _buildCheck(
              context,
              checked: userData.lookForWork,
              icon: Icons.work,
              text: "Looking for Work",
            ),
            _buildCheck(
              context,
              checked: userData.lookForDevs,
              icon: Icons.person,
              text: "Looking for Developers",
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Center(
          child: Text(userData.city),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Material(
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                children: <Widget>[
                  _buildMain(context),
                  SizedBox(height: 12.0),
                  _buildBottom(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
