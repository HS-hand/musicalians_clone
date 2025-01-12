import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'writereview.dart';
import 'allreview.dart';
import 'mypage.dart';

class MuseWikiPage extends StatefulWidget {
  const MuseWikiPage({super.key});

  @override
  State<MuseWikiPage> createState() => _MuseWikiPageState();
}

class _MuseWikiPageState extends State<MuseWikiPage> {
  int _selectedIndex = 0; // 현재 선택된 내비게이션 인덱스

  final List<Map<String, String>> musicalRankings = [
    {
      'title': '알라딘',
      'venue': '샤롯데씨어터',
      'date': '2024.11.22 - 2025.06.22',
      'poster': 'assets/images/알라딘.png',
    },
    {
      'title': '시라노',
      'venue': '예술의전당 CJ 토월극장',
      'date': '2024.12.6 ~ 2025.2.23',
      'poster': 'assets/images/시라노.png',
    },
    {
      'title': '지킬앤하이드',
      'venue': '블루스퀘어 신한카드홀',
      'date': '2024.11.29 - 2025.05.18',
      'poster': 'assets/images/지킬앤하이드.png',
    },
  ];

  // 최신 리뷰 한 건을 가져오는 Future
  late Future<Map<String, dynamic>?> _latestReviewFuture;

  @override
  void initState() {
    super.initState();
    _latestReviewFuture = fetchLatestReview();
  }

  Future<Map<String, dynamic>?> fetchLatestReview() async {
    try {
      final uri = Uri.parse('http://192.168.0.3:8080/review');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isEmpty) {
          return null; // 리뷰가 없는 경우
        }
        // 가장 첫 번째 아이템(가장 최신 리뷰)
        final latest = data[0] as Map<String, dynamic>;
        return latest;
      } else {
        debugPrint('Failed to load reviews: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching latest review: $e');
      return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar
      appBar: AppBar(
        title: const Text('뮤즈위키'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      // 스크롤이 가능한 부분
      body: ListView(
        children: [
          // 섹션 1: 이미지 슬라이더
          SizedBox(
            height: 300,
            child: PageView(
              children: [
                Image.asset(
                  'assets/images/musewiki_section1.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/musewiki_section2.png',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'assets/images/musewiki_section3.png',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),

          // 섹션 2: 뮤지컬 랭킹
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '뮤지컬리언 랭킹',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: musicalRankings.length,
                  itemBuilder: (context, index) {
                    final musical = musicalRankings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 포스터 이미지
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              musical['poster']!,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // 뮤지컬 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${musical['title']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('장소: ${musical['venue']}'),
                                Text('기간: ${musical['date']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 섹션 3
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // '뮤지컬리언 최신 후기' + 우측 상단 '더보기'
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        '뮤지컬리언 최신 후기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // "더보기" 클릭 → AllReviewPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllReviewPage(),
                            ),
                          );
                        },
                        child: const Text(
                          '더보기',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 최신 리뷰 1개 표시 (FutureBuilder)
                FutureBuilder<Map<String, dynamic>?>(
                  future: _latestReviewFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('최신 리뷰를 불러오는 중 오류가 발생했습니다.'),
                      );
                    }

                    final latestReview = snapshot.data;
                    if (latestReview == null) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('아직 등록된 리뷰가 없습니다.'),
                      );
                    }

                    // 리뷰 필드
                    final title = latestReview['title'] ?? '';
                    final musicalTitle = latestReview['musicalTitle'] ?? '';
                    final content = latestReview['content'] ?? '';
                    final nickname = latestReview['nickname'] ?? '';
                    final createdAtRaw = latestReview['createdAt'] ?? '';

                    // 작성일(yyyy-MM-dd) 형식으로 변환
                    String createdAtDisplay = createdAtRaw;
                    try {
                      final parsedDate = DateTime.parse(createdAtRaw);
                      createdAtDisplay =
                          DateFormat('yyyy-MM-dd').format(parsedDate);
                    } catch (_) {
                      // 파싱 실패하면 그냥 원본
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '제목: $title (뮤지컬: $musicalTitle)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('작성자: $nickname'),
                          Text('작성일: $createdAtDisplay'),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),

                // 하단 중앙 버튼: 리뷰 작성
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewPage(
                            email: Provider.of<AuthProvider>(context,
                                    listen: false)
                                .email!,
                          ),
                        ),
                      );
                    },
                    child: const Text('리뷰 작성'),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),

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
