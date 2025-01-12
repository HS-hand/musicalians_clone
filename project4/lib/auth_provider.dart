import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _email; // 로그인한 사용자의 이메일

  String? get email => _email;

  void login(String email) {
    _email = email;
    notifyListeners(); // 상태 변경 알림
  }

  void logout() {
    _email = null;
    notifyListeners(); // 상태 변경 알림
  }
}
