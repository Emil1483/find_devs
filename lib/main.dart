import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './routes/home_route.dart';
import './routes/auth_route.dart';
import './routes/loading_route.dart';
import './routes/projects_route.dart';
import './routes/account_route.dart';
import './routes/chat_route.dart';
import './routes/messages_route.dart';
import './providers/user.dart';
import './providers/devs.dart';
import './providers/chat.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: User()),
        ChangeNotifierProvider.value(value: Devs()),
      ],
      child: MaterialApp(
        title: 'Find Devs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Color(0xFF161B21),
          accentColor: Color(0xFFF4A342),
          indicatorColor: Color(0xFFEFB197),
          toggleableActiveColor: Color(0xFFF4A342),
          cardColor: Color(0xFF29323D),
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
            body1: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
            ),
            body2: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
            subtitle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            title: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 26.0,
            ),
            overline: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        routes: {
          HomeRoute.routeName: (_) => HomeRoute(),
          AuthRoute.routeName: (_) => AuthRoute(),
          AccountRoute.routeName: (_) => AccountRoute(),
          ProjectsRoute.routeName: (_) => ProjectsRoute(),
          MessagesRoute.routeName: (_) => MessagesRoute(),
          ChatRoute.routeName: (BuildContext context) {
            UserData userData = ModalRoute.of(context).settings.arguments;

            return ChangeNotifierProvider<Chat>.value(
              value: Chat(userData, Provider.of<User>(context, listen: false)),
              child: ChatRoute(),
            );
          },
        },
        home: LoadingRoute(),
      ),
    );
  }
}
