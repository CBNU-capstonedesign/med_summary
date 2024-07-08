import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryService {
  final String _baseUrl = 'https://naveropenapi.apigw.ntruss.com/text-summary/v1/summarize';

  Future<String> summarizeText(String title, String content) async {
    final String clientId = dotenv.env['X-Naver-Client-Id']!;
    final String clientSecret = dotenv.env['X-Naver-Client-Secret']!;

    debugPrint(clientId);
    debugPrint(clientSecret);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
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
      // 응답 본문을 UTF-8로 디코딩
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint(utf8.decode(response.bodyBytes));  // 수정된 부분
      return data['summary'] ?? '요약된 내용이 없습니다';
    } else {
      throw Exception('요약 요청 실패: ${response.statusCode}');
    }
  }
}
