import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  SignUpPage({super.key});

  Future<void> _signUp(BuildContext context) async {
    final id = _idController.text;
    final password = _passwordController.text;
    final nickname = _nicknameController.text;

    if (id.isEmpty || password.isEmpty || nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.3:8080/signup'), // 서버의 회원가입 API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': id, 'password': password, 'nickname': nickname}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 성공!')),
        );
        Navigator.pop(context); // 회원가입 완료 후 이전 화면으로 이동
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 요청 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/loginpage_logo.png'),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: 'Nickname'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signUp(context),
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
