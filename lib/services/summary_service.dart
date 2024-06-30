import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class SummaryService {
  final String _baseUrl = 'https://naveropenapi.apigw.ntruss.com/text-summary/v1/summarize';

  Future<String> summarizeText(String title, String content) async {
    final String clientId = dotenv.env['X-Naver-Client-Id']!;
    final String clientSecret = dotenv.env['X-Naver-Client-Secret']!;

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'document': {
          'title': title,
          'content': content,
        },
        'option': {
          'language': 'ko',
          'model': 'general',
          'tone': 0,
          'summaryCount': 3,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary'] ?? '요약된 내용이 없습니다';
    } else {
      throw Exception('A요약 요청 실패: ${response.statusCode}');
    }
  }
}
