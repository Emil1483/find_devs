import 'package:flutter/material.dart';

import '../providers/user.dart';
import '../routes/dev_details_route.dart';

class UserTile extends StatefulWidget {
  final UserData userData;

  UserTile({@required this.userData});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _controller.forward();
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMain(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: widget.userData.imageUrl == null ||
                  widget.userData.imageUrl.isEmpty
              ? Center(child: Icon(Icons.person, size: 36.0))
              : Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.userData.imageUrl),
                    radius: 22,
                  ),
                ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.userData.username, style: theme.headline),
              SizedBox(height: 6.0),
              Text(
                widget.userData.about,
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
          Container(
            width: 82,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.subtitle,
            ),
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
              checked: widget.userData.lookToCollab,
              icon: Icons.code,
              text: "Looking to Collaborate",
            ),
            _buildCheck(
              context,
              checked: widget.userData.lookForWork,
              icon: Icons.work,
              text: "Looking for Work",
            ),
            _buildCheck(
              context,
              checked: widget.userData.lookForDevs,
              icon: Icons.person,
              text: "Looking for Developers",
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Center(
          child: Text(
            widget.userData.city,
            style: theme.overline,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(8.0);
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.5, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DevDetailsRoute(userData: widget.userData),
              ),
            ),
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
      ),
    );
  }
}
