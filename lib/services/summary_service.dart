import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  final String apiKeyId = 'YOUR_CLIENT_ID';
  final String apiKey = 'YOUR_CLIENT_SECRET';

  Future<String> summarizeText(String title, String content) async {
    final String apiUrl = 'https://naveropenapi.apigw.ntruss.com/text-summary/v1/summarize';

    final Map<String, dynamic> requestBody = {
      'document': {
        'title': title,
        'content': content,
      },
      'option': {
        'language': 'ko',
        'model': 'news',
        'tone': 2,
        'summaryCount': 3,
      }
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': apiKeyId,
        'X-NCP-APIGW-API-KEY': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['summary'];
    } else {
      throw Exception('Failed to summarize text');
    }
  }
}
