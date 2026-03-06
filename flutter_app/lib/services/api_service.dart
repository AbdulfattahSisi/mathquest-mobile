import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import '../models/question_model.dart';
import '../models/duel_model.dart';

/// All API calls to the FastAPI backend.
class ApiService {
  // Change to your machine IP when testing on a real device
  // 10.0.2.2 = Android emulator localhost, localhost = Windows/desktop/web
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ── Token helpers ─────────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: 'access_token');

  Future<void> saveToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'access_token');

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    _checkStatus(res);
    final data = jsonDecode(res.body);
    return data['access_token'] as String;
  }

  Future<String> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    _checkStatus(res);
    final data = jsonDecode(res.body);
    return data['access_token'] as String;
  }

  Future<UserModel> getMe() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  Future<List<SubjectModel>> getSubjects() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/questions/subjects'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<List<QuestionModel>> getQuestions({
    String? subjectSlug,
    int? difficulty,
    int limit = 10,
  }) async {
    final params = {
      if (subjectSlug != null) 'subject_slug': subjectSlug,
      if (difficulty != null) 'difficulty': difficulty.toString(),
      'limit': limit.toString(),
    };
    final uri = Uri.parse('$_baseUrl/questions').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _authHeaders());
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<QuestionModel> getQuestionWithAnswer(String questionId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/questions/$questionId/answer'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return QuestionModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<QuestionModel>> generateQuestions({
    required String subjectSlug,
    int difficulty = 2,
    int count = 5,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/questions/generate'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'subject_slug': subjectSlug,
        'difficulty': difficulty,
        'count': count,
      }),
    );
    _checkStatus(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Duels ─────────────────────────────────────────────────────────────────

  Future<DuelModel> createDuel({
    required String subjectId,
    String mode = 'solo',
    int totalQuestions = 10,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/duels/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'subject_id': subjectId,
        'mode': mode,
        'total_questions': totalQuestions,
      }),
    );
    _checkStatus(res);
    return DuelModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<DuelResult> submitAnswer({
    required String duelId,
    required String questionId,
    required String answerGiven,
    required int timeTakenMs,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/duels/$duelId/answer'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'question_id': questionId,
        'answer_given': answerGiven,
        'time_taken_ms': timeTakenMs,
      }),
    );
    _checkStatus(res);
    return DuelResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/leaderboard/?limit=$limit'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProgress() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/progress'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getAIProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/ai-profile'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/analytics'),
      headers: await _authHeaders(),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Error Handling ────────────────────────────────────────────────────────

  void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      final detail = body['detail'] ?? 'Erreur ${res.statusCode}';
      throw ApiException(detail.toString(), res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
