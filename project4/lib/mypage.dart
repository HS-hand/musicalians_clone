import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'musewiki.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _selectedIndex = 4; // "마이페이지" 탭 인덱스

  late Future<String?> _nicknameFuture;
  late Future<List<dynamic>> _userReviewsFuture;

  // 리뷰 삭제 요청
  Future<void> deleteReview(int reviewId) async {
    final uri = Uri.parse('http://192.168.0.3:8080/review/$reviewId');
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      // 삭제 성공 → 목록 갱신
      setState(() {
        _userReviewsFuture = _nicknameFuture.then((nickname) {
          if (nickname == null) return <dynamic>[];
          return fetchReviewsByNickname(nickname);
        });
      });
    } else {
      // 삭제 실패
      print('Failed to delete review: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 삭제 실패: ${response.body}')),
      );
    }
  }

  // 리뷰 수정 요청 (PUT)
  Future<void> updateReview(
    int reviewId,
    String newTitle,
    String newMusicalTitle,
    String newContent,
  ) async {
    final uri = Uri.parse('http://192.168.0.3:8080/review/$reviewId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': newTitle,
        'musicalTitle': newMusicalTitle,
        'content': newContent,
      }),
    );

    if (response.statusCode == 200) {
      // 수정 성공 → 목록 재갱신
      setState(() {
        _userReviewsFuture = _nicknameFuture.then((nickname) {
          if (nickname == null) return <dynamic>[];
          return fetchReviewsByNickname(nickname);
        });
      });
    } else {
      // 수정 실패
      print('Failed to update review: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 수정 실패: ${response.body}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // 로그인 사용자 이메일
    final email = Provider.of<AuthProvider>(context, listen: false).email;

    //이메일로 닉네임 가져오기
    _nicknameFuture = fetchNicknameByEmail(email);

    //닉네임 가져온 뒤, 해당 닉네임의 리뷰 목록 가져오기
    _userReviewsFuture = _nicknameFuture.then((nickname) {
      if (nickname == null) {
        return <dynamic>[]; // 없는 경우 빈 목록
      }
      return fetchReviewsByNickname(nickname);
    });
  }

  Future<String?> fetchNicknameByEmail(String? email) async {
    if (email == null) return null;
    final uri = Uri.parse('http://192.168.0.3:8080/user/$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['nickname'] as String?;
    }
    return null;
  }

  Future<List<dynamic>> fetchReviewsByNickname(String nickname) async {
    final uri =
        Uri.parse('http://192.168.0.3:8080/user_reviews_by_nickname/$nickname');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    }
    return [];
  }

  // 바텀 네비게이션 탭 변경 시
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // 뮤즈위키로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MuseWikiPage()),
      );
    }
  }

  // 리뷰 삭제 다이얼로그
  void _showDeleteDialog(int reviewId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '리뷰를 삭제할까요?',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 확인
                deleteReview(reviewId);
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 리뷰 수정 다이얼로그
  void _showEditDialog(
    int reviewId,
    String oldTitle,
    String oldMusicalTitle,
    String oldContent,
  ) {
    final titleController = TextEditingController(text: oldTitle);
    final musicalTitleController = TextEditingController(text: oldMusicalTitle);
    final contentController = TextEditingController(text: oldContent);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('리뷰 수정', style: TextStyle(fontSize: 20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 수정할 "제목"
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 8),
                // 수정할 "뮤지컬 제목"
                TextField(
                  controller: musicalTitleController,
                  decoration: const InputDecoration(labelText: '뮤지컬 제목'),
                ),
                const SizedBox(height: 8),
                // 수정할 "내용"
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // "저장" → updateReview 호출
                final newTitle = titleController.text.trim();
                final newMusicalTitle = musicalTitleController.text.trim();
                final newContent = contentController.text.trim();

                updateReview(reviewId, newTitle, newMusicalTitle, newContent);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          // (섹션 1) 사용자 닉네임 표시
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: FutureBuilder<String?>(
              future: _nicknameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final nickname = snapshot.data;
                if (nickname == null) {
                  return const Center(child: Text('닉네임을 불러올 수 없습니다.'));
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(nickname, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(thickness: 1, height: 1),

          // (섹션 2) 내가 작성한 리뷰 목록
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '내가 작성한 리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _userReviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('아직 작성한 리뷰가 없습니다.')),
                );
              }

              // 리뷰 목록 표시
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final r = reviews[index] as Map<String, dynamic>;
                  final reviewId = r['id'] as int?;
                  final title = r['title'] ?? '';
                  final musicalTitle = r['musicalTitle'] ?? '';
                  final content = r['content'] ?? '';

                  return ListTile(
                    title: Text('$title (뮤지컬: $musicalTitle)'),
                    subtitle: Text(content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 수정 아이콘
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            if (reviewId != null) {
                              _showEditDialog(
                                  reviewId, title, musicalTitle, content);
                            }
                          },
                        ),
                        // 삭제 아이콘
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            if (reviewId != null) {
                              _showDeleteDialog(reviewId);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      // 하단 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '뮤즈위키',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '일정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: '티켓',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '데이터',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
