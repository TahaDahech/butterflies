import 'package:butterflies/components/screens/dashboard_screen.dart';
import 'package:butterflies/components/screens/sign_in.dart';
import 'package:flutter/material.dart';

import '../../data/repository/firebase_auth_repository.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  AuthGateState createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  final Auth _authRepository = Auth();

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    bool isLoggedIn = await _authRepository.getLoginState();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const DashboardScreen() : const SignInScreen();
  }
}
