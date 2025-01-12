import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// intl 패키지 임포트
import 'package:intl/intl.dart';

class AllReviewPage extends StatefulWidget {
  const AllReviewPage({Key? key}) : super(key: key);

  @override
  State<AllReviewPage> createState() => _AllReviewPageState();
}

class _AllReviewPageState extends State<AllReviewPage> {
  late Future<List<dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchAllReviews();
  }

  Future<List<dynamic>> fetchAllReviews() async {
    try {
      final uri = Uri.parse('http://192.168.0.3:8080/review');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data; // 리뷰 목록
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모든 리뷰'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 등록된 리뷰가 없습니다.'));
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index] as Map<String, dynamic>;
              final title = review['title'] ?? '';
              final musicalTitle = review['musicalTitle'] ?? '';
              final content = review['content'] ?? '';
              final nickname = review['nickname'] ?? '';
              final createdAt = review['createdAt'] ?? '';

              // createdAt을 DateTime 형태로 파싱
              DateTime? parsedDate;
              try {
                parsedDate = DateTime.parse(createdAt);
              } catch (_) {
                // 파싱 실패 시 parsedDate를 null로 유지
              }

              // 연-월-일 포맷
              String displayDate = createdAt; // 기본은 원본
              if (parsedDate != null) {
                displayDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('$title (뮤지컬: $musicalTitle)'),
                  subtitle: Text(
                    '작성자: $nickname\n작성일: $displayDate\n\n$content',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
