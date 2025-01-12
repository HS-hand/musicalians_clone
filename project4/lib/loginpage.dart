import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'signuppage.dart'; // 회원가입 페이지
import 'musewiki.dart'; // 로그인 성공 시 이동할 페이지
import 'auth_provider.dart'; // AuthProvider import

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    final id = _idController.text;
    final password = _passwordController.text;

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID와 Password를 입력해주세요.')),
      );
      return;
    }

    try {
      final url = Uri.parse('http://192.168.0.3:8080/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': id, 'password': password}),
      );

      if (response.statusCode == 200) {
        // 로그인 성공 시 이메일 저장
        Provider.of<AuthProvider>(context, listen: false).login(id);

        // MuseWikiPage로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MuseWikiPage()),
        );
      } else {
        // 로그인 실패 시 서버에서 보낸 error 메시지 처리
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error'] ?? '로그인 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 요청 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
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
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _login(context);
                  },
                  child: const Text('로그인'),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    ); // 회원가입 페이지로 이동
                  },
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
