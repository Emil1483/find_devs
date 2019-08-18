import 'package:flutter/material.dart';

import './routes/home_route.dart';
import './routes/auth_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Devs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(
          body2: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
          title: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 22.0,
          ),
        ),
      ),
      routes: {
        //"/": (BuildContext context) => HomeRoute(),
        //AuthRoute.routeName: (BuildContext context) => AuthRoute(),
      },
      home: AuthRoute(),
    );
  }
}
