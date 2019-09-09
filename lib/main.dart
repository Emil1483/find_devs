import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './routes/home_route.dart';
import './routes/auth_route.dart';
import './routes/loading_route.dart';
import './routes/account_route.dart';
import './providers/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: User()),
      ],
      child: MaterialApp(
        title: 'Find Devs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Color(0xFF161B21),
          accentColor: Color(0xFFF4A342),
          toggleableActiveColor: Color(0xFFF4A342),
          appBarTheme: AppBarTheme(
            color: Color(0xFF222A33),
            textTheme: TextTheme(
              title: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 22.0,
              ),
            ),
          ),
          textTheme: TextTheme(
            display2: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            body2: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            title: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 26.0,
            ),
          ),
        ),
        routes: {
          HomeRoute.routeName: (_) => HomeRoute(),
          AuthRoute.routeName: (_) => AuthRoute(),
          AccountRoute.routeName: (_) => AccountRoute(),
        },
        home: LoadingRoute(),
      ),
    );
  }
}
