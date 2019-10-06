import 'package:flutter/foundation.dart';

import './user.dart' show UserData;

class Chat with ChangeNotifier {
  final UserData _userData;

  Chat(this._userData);

  UserData get userData => _userData.copy();
}
