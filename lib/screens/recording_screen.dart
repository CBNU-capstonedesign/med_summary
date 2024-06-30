import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/summary_service.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final SummaryService _summaryService = SummaryService();
  String _summaryResult = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '음성 인식을 시작하려면 버튼을 누르세요';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _getSummary() async {
    if (_text.isEmpty) {
      setState(() {
        _summaryResult = '음성 인식된 텍스트가 없습니다.';
      });
      return;
    }

    try {
      String summary = await _summaryService.summarizeText(
        ' ', // 제목
        _text,
      );
      setState(() {
        _summaryResult = summary;
      });
    } catch (e) {
      setState(() {
        _summaryResult = '요약 요청 실패: $e';
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('처치 기록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _listen,
              child: Text(_isListening ? '듣는 중...' : '음성 인식 시작'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getSummary,
              child: Text('요약 요청'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '음성 인식 결과:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Text(_text),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '요약 결과:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Text(_summaryResult),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
