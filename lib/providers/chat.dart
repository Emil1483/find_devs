import 'package:flutter/foundation.dart';

import './user.dart' show UserData;

class Chat with ChangeNotifier {
  final UserData _userData;

  Chat(this._userData);

  UserData get userData => _userData.copy();

  //TODO: Use https://medium.com/flutter-community/building-a-chat-app-with-flutter-and-firebase-from-scratch-9eaa7f41782e to complete the chat route
}
