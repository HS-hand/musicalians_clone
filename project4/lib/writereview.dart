import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WriteReviewPage extends StatefulWidget {
  final String email;

  const WriteReviewPage({super.key, required this.email});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  String? _nickname;

  final _titleController = TextEditingController(); // 리뷰 제목
  final _musicalController = TextEditingController(); // 뮤지컬 제목
  final _contentController = TextEditingController(); // 리뷰 내용

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  // 작성자의 닉네임 가져오기
  Future<void> _loadNickname() async {
    final uri = Uri.parse('http://192.168.0.3:8080/user/${widget.email}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nickname = data['nickname'];
        });
      } else {
        print('Failed to fetch nickname: ${response.body}');
      }
    } catch (e) {
      print('Error fetching nickname: $e');
    }
  }

  // 리뷰 작성 요청
  Future<void> _submitReview() async {
    // 서버의 /review 엔드포인트 주소
    final uri = Uri.parse('http://192.168.0.3:8080/review');

    final reviewTitle = _titleController.text.trim();
    final musicalTitle = _musicalController.text.trim();
    final reviewContent = _contentController.text.trim();

    // _nickname이 로드되지 않았다면 기본값 사용
    final nickname = _nickname ?? 'Anonymous';

    // 유효성 검사
    if (reviewTitle.isEmpty || musicalTitle.isEmpty || reviewContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        // 서버에 저장되어있는 JSON 형식과 맞춰서
        body: jsonEncode({
          'title': reviewTitle,
          'musicalTitle': musicalTitle,
          'content': reviewContent,
          'nickname': nickname,
        }),
      );

      if (response.statusCode == 201) {
        // 리뷰 등록 성공
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 성공적으로 등록되었습니다.')),
        );
        Navigator.pop(context); // 작성 페이지 닫기 or 다른 화면 이동
      } else {
        // 리뷰 등록 실패
        final body = jsonDecode(response.body);
        final error = body['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 등록 실패: $error')),
        );
      }
    } catch (e) {
      // 네트워크 오류, 예외 처리
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 등록 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 닉네임 표시
              Text(
                '작성자: ${_nickname ?? '로딩 중...'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // 리뷰 제목
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '리뷰 제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // 뮤지컬 제목
              TextField(
                controller: _musicalController,
                decoration: const InputDecoration(
                  labelText: '뮤지컬 제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // 리뷰 내용
              TextField(
                controller: _contentController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: '리뷰 내용',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // 작성 버튼
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text('작성 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
