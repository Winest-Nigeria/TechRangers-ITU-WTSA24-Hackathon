import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:winest_chatbot/models/message.dart';

class GeminiService {

  static Future<Message> getResponse(String body) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final uri = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent')
        .replace(queryParameters: {
      'key': apiKey,
    });
    final response = await http.post(uri, body: body);
    if (response.statusCode == 200) {
      final Map data = json.decode(response.body);
      return Message.fromJson(data['candidates'][0]['content']);
    } else {
      throw Exception('Failed to load symbols');
    }
  }
}
