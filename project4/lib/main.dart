import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart'; // AuthProvider import
import 'package:project4/loginpage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뮤즈위키',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // 로그인 페이지로 시작
    );
  }
}
