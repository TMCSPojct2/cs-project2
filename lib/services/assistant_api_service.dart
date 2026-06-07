import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/role_context.dart';

class AssistantApiService {
  AssistantApiService._();

  static final AssistantApiService instance = AssistantApiService._();
  static final Uri _endpoint = Uri.parse('https://abo3lie.com/api/chat');

  Future<String> sendMessage({required String message, required UserRole role}) async {
    final response = await http.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Assistant service is unavailable.');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      throw Exception('Assistant service returned an empty response.');
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final value = decoded['response'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }
    throw Exception('Assistant response format is invalid.');
  }
}