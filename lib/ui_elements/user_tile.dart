import 'package:flutter/material.dart';

import '../providers/user.dart';

class UserTile extends StatelessWidget {
  final UserData userData;

  UserTile({@required this.userData});

  Widget _buildMain(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
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
              Text(userData.username, style: theme.headline),
              SizedBox(height: 6.0),
              Text(
                userData.about,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: theme.body1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheck(BuildContext context,
      {bool checked, IconData icon, String text}) {
    TextTheme theme = Theme.of(context).textTheme;
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
            style: theme.subtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
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
          child: Text(
            userData.city,
            style: theme.overline,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(8.0);
    return Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
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
    );
  }
}
