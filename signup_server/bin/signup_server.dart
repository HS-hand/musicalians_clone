import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'db.dart'; // DB 초기화/삽입/조회 함수들이 정의된 파일

// CORS 설정
final _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Origin, Content-Type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
};

void main() async {
  //데이터베이스 초기화
  initializeDatabase();

  //라우터 정의
  final router = Router();

  // 회원가입
  router.post('/signup', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final email = data['email'] as String?;
    final password = data['password'] as String?;
    final nickname = data['nickname'] as String?;

    if (email == null || password == null || nickname == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid input'}));
    }

    if (insertUser(email, password, nickname)) {
      return Response(
        201,
        body: jsonEncode({'message': 'User registered successfully'}),
      );
    } else {
      return Response(
        400,
        body: jsonEncode({'error': 'User already exists'}),
      );
    }
  });

  // 로그인
  router.post('/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final email = data['email'] as String?;
    final password = data['password'] as String?;

    if (email == null || password == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid input'}));
    }

    final user = findUserByEmail(email);

    if (user == null || user['password'] != password) {
      return Response(401,
          body: jsonEncode({'error': 'Invalid email or password'}));
    }

    return Response(200, body: jsonEncode({'message': 'Login successful'}));
  });

  // 닉네임 조회: /user/<email>
  router.get('/user/<email>', (Request request, String email) async {
    final user = findUserByEmail(email);

    if (user == null) {
      return Response(404, body: jsonEncode({'error': 'User not found'}));
    }

    return Response(200, body: jsonEncode({'nickname': user['nickname']}));
  });

  // 리뷰 작성 (POST /review)
  router.post('/review', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final title = data['title'] as String?;
    final musicalTitle = data['musicalTitle'] as String?;
    final content = data['content'] as String?;
    final nickname = data['nickname'] as String?;

    if (title == null ||
        musicalTitle == null ||
        content == null ||
        nickname == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid input'}));
    }

    // DB에 리뷰 삽입
    final success = insertReview(
      title: title,
      musicalTitle: musicalTitle,
      content: content,
      nickname: nickname,
    );

    if (success) {
      return Response(201, body: jsonEncode({'message': 'Review created'}));
    } else {
      return Response(500,
          body: jsonEncode({'error': 'Failed to insert review'}));
    }
  });

  // 리뷰 조회 (GET /review)
  router.get('/review', (Request request) async {
    final reviews = getAllReviews(); // DB에서 리뷰 목록 조회
    return Response.ok(
      jsonEncode(reviews),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // 닉네임 기반 리뷰 목록
  router.get('/user_reviews_by_nickname/<nickname>',
      (Request request, String nickname) async {
    final reviews = getReviewsByNickname(nickname);
    return Response.ok(
      jsonEncode(reviews),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // 리뷰 삭제 (DELETE /review/<id>)
  router.delete('/review/<id>', (Request request, String id) async {
    final reviewId = int.tryParse(id);
    if (reviewId == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid review ID'}));
    }

    final success = deleteReviewById(reviewId);
    if (success) {
      return Response(200, body: jsonEncode({'message': 'Review deleted'}));
    } else {
      return Response(404, body: jsonEncode({'error': 'Review not found'}));
    }
  });

  // 리뷰 수정 (PUT /review/<id>)
  router.put('/review/<id>', (Request request, String id) async {
    final reviewId = int.tryParse(id);
    if (reviewId == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid review ID'}));
    }

    final body = await request.readAsString();
    final data = jsonDecode(body);

    final title = data['title'] as String?;
    final musicalTitle = data['musicalTitle'] as String?;
    final content = data['content'] as String?;

    if (title == null || musicalTitle == null || content == null) {
      return Response(400, body: jsonEncode({'error': 'Invalid input'}));
    }

    final success = updateReviewById(
      reviewId: reviewId,
      title: title,
      musicalTitle: musicalTitle,
      content: content,
    );

    if (success) {
      return Response(200, body: jsonEncode({'message': 'Review updated'}));
    } else {
      return Response(404, body: jsonEncode({'error': 'Review not found'}));
    }
  });

  //파이프라인: 미들웨어 + 라우터
  final handler = const Pipeline()
      .addMiddleware(logRequests()) // 요청 로깅
      .addMiddleware(corsHeaders(headers: _corsHeaders)) // CORS 허용
      .addHandler(router);

  //서버 실행
  final server = await io.serve(handler, '192.168.0.3', 8080);
  print('Server running on 192.168.0.3:${server.port}');
}
