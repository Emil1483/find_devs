import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/user.dart';
import './chat_route.dart';
import '../ui_elements/gradient button.dart';

class DevDetailsRoute extends StatelessWidget {
  final UserData userData;

  DevDetailsRoute({@required this.userData});

  static Widget _buildImage(UserData userData) {
    return userData.imageUrl == null || userData.imageUrl.isEmpty
        ? Center(
            child: Container(
              width: 184.0,
              child: Image.asset("assets/account.png"),
            ),
          )
        : Center(
            child: Hero(
              tag: userData,
              child: CircleAvatar(
                radius: 92.0,
                backgroundImage: NetworkImage(
                  userData.imageUrl,
                ),
              ),
            ),
          );
  }

  static Widget _buildTop(BuildContext context, UserData userData) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (portrait) {
      final bool hasAboutText = userData.about.length > 0;
      return Column(
        children: <Widget>[
          _buildImage(userData),
          if (hasAboutText) SizedBox(height: 24.0),
          if (hasAboutText) Text(userData.about, textAlign: TextAlign.center),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: _buildImage(userData),
          ),
          Expanded(
            child: Text(userData.about),
          ),
        ],
      );
    }
  }

  static Widget _buildCheck(
    BuildContext context, {
    @required bool checked,
    @required IconData icon,
    @required String text,
  }) {
    TextTheme theme = Theme.of(context).textTheme;

    Widget buildIcon() {
      return Icon(
        icon,
        color: checked
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      );
    }

    Widget buildText() {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: theme.subhead.copyWith(fontWeight: FontWeight.w300),
      );
    }

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Row(
          children: <Widget>[
            buildIcon(),
            SizedBox(width: 16.0),
            buildText(),
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          buildIcon(),
          buildText(),
        ],
      );
    }
  }

  static Widget _buildChecks({
    @required BuildContext context,
    @required UserData userData,
  }) {
    List<Widget> children = [
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
    ];
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      );
    }
  }

  static Widget buildMain({
    @required BuildContext context,
    @required UserData userData,
  }) {
    TextTheme theme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        _buildTop(context, userData),
        _Buttons(userData.about),
        Text(
          "City/state - ${userData.city}",
          textAlign: TextAlign.center,
          style: theme.subhead,
        ),
        SizedBox(height: 12.0),
        _buildChecks(
          context: context,
          userData: userData,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData.username),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          Navigator.of(context).pushNamed(
            ChatRoute.routeName,
            arguments: userData,
          );
        },
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        children: <Widget>[
          buildMain(
            context: context,
            userData: userData,
          ),
        ],
      ),
    );
  }
}

class _Url {
  final String url;
  final String name;

  _Url({
    @required this.url,
    @required this.name,
  });
}

class _Buttons extends StatefulWidget {
  final String about;

  _Buttons(this.about);

  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons>
    with SingleTickerProviderStateMixin {
  List<_Url> _urls;
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _getUrls();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getUrls() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _controller.forward();
      _urls = [
        _Url(name: "djupvik.tech", url: "https://www.djupvik.tech"),
      ];
    });
  }

  Widget _buildButton(_Url url) {
    ThemeData theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final double value = Curves.easeOutCubic.transform(
          math.max(_controller.value * 2 - 1, 0),
        );
        return Transform.scale(
          scale: value,
          child: GradientButton(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            onPressed: () {},
            gradient: LinearGradient(
              colors: [
                theme.accentColor,
                theme.indicatorColor,
              ],
            ),
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 3),
              child: Text(
                url.name,
                style: theme.textTheme.button,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_urls == null || _urls.length == 0) return Container(height: 24.0);
    List<Widget> children = _urls.map((_Url url) => _buildButton(url)).toList();
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final double value = Curves.easeInOutCubic.transform(
          math.min(_controller.value * 2, 1),
        );
        return Container(
          height: value * 58.0 + 24,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          ),
        );
      },
    );
  }
}
