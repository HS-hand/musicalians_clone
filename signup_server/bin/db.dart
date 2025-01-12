import 'package:sqlite3/sqlite3.dart';

// SQLite 데이터베이스 파일 오픈
late Database db;

// 데이터베이스 초기화: users 테이블 생성 (nickname 필드 추가)
void initializeDatabase() {
  db = sqlite3.open('users.db');

  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      nickname TEXT NOT NULL
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      musicalTitle TEXT NOT NULL,
      content TEXT NOT NULL,
      nickname TEXT NOT NULL,
      createdAt TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
    );
  ''');
}

// 사용자 삽입: email, password, nickname 모두 저장
bool insertUser(String email, String password, String nickname) {
  try {
    final stmt = db.prepare(
      'INSERT INTO users (email, password, nickname) VALUES (?, ?, ?)',
    );
    stmt.execute([email, password, nickname]);
    stmt.dispose();
    return true;
  } catch (e) {
    // 예: 중복된 email이면 에러 발생
    return false;
  }
}

// 사용자 조회: email로 찾은 뒤, nickname 포함해서 반환
Map<String, dynamic>? findUserByEmail(String email) {
  final stmt = db.prepare('SELECT * FROM users WHERE email = ?');
  final result = stmt.select([email]);
  stmt.dispose();

  if (result.isEmpty) return null;

  final row = result.first;
  return {
    'id': row['id'],
    'email': row['email'],
    'password': row['password'],
    'nickname': row['nickname'],
  };
}

// 리뷰 삽입
bool insertReview({
  required String title,
  required String musicalTitle,
  required String content,
  required String nickname,
}) {
  try {
    final stmt = db.prepare('''
      INSERT INTO reviews (title, musicalTitle, content, nickname, createdAt)
      VALUES (?, ?, ?, ?, ?)
    ''');
    stmt.execute([
      title,
      musicalTitle,
      content,
      nickname,
      DateTime.now().toIso8601String(), // 작성 시각
    ]);
    stmt.dispose();
    return true;
  } catch (e) {
    print('Insert review error: $e');
    return false;
  }
}

List<Map<String, dynamic>> getAllReviews() {
  // createdAt을 DESC로 정렬 → 최신 리뷰가 먼저 오도록
  final result = db.select('SELECT * FROM reviews ORDER BY createdAt DESC;');

  // Row를 Map으로 변환
  return result
      .map((row) => {
            'id': row['id'],
            'title': row['title'],
            'musicalTitle': row['musicalTitle'],
            'content': row['content'],
            'nickname': row['nickname'],
            'createdAt': row['createdAt'],
          })
      .toList();
}

//닉네임으로 리뷰 조회
List<Map<String, dynamic>> getReviewsByNickname(String nickname) {
  final stmt = db.prepare('''
    SELECT *
    FROM reviews
    WHERE nickname = ?
    ORDER BY createdAt DESC
  ''');
  final result = stmt.select([nickname]);
  stmt.dispose();

  return result
      .map((row) => {
            'id': row['id'],
            'title': row['title'],
            'musicalTitle': row['musicalTitle'],
            'content': row['content'],
            'nickname': row['nickname'],
            'createdAt': row['createdAt'],
          })
      .toList();
}

//리뷰 제거
bool deleteReviewById(int reviewId) {
  try {
    final stmt = db.prepare('DELETE FROM reviews WHERE id = ?');
    stmt.execute([reviewId]);
    stmt.dispose();
    return true;
  } catch (e) {
    print('Delete review error: $e');
    return false;
  }
}

//리뷰 수정
bool updateReviewById({
  required int reviewId,
  required String title,
  required String musicalTitle,
  required String content,
}) {
  try {
    final stmt = db.prepare('''
      UPDATE reviews
      SET title = ?, musicalTitle = ?, content = ?
      WHERE id = ?
    ''');
    stmt.execute([title, musicalTitle, content, reviewId]);
    stmt.dispose();
    return true;
  } catch (e) {
    print('Update review error: $e');
    return false;
  }
}
