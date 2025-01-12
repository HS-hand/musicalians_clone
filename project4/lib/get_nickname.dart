import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> fetchNickname(String email) async {
  final uri = Uri.parse('http://192.168.0.3:8080/user/$email');
  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['nickname'];
    } else {
      print('Failed to fetch nickname: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching nickname: $e');
    return null;
  }
}
