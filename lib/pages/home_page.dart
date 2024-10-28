import 'dart:async';

import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:audio_waveforms/audio_waveforms.dart';

import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //late RecorderController controller;
  final PlayerController _controller = PlayerController();
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentDuration = 0;
  int _totalDuration = 0;

  bool isRecording = false;
  List<Map<String, dynamic>> patients = [];

  Duration recordingDuration = Duration.zero; // 녹음 시간 추적
  Timer? _timer; // 타이머 업데이트용
  bool isPaused = false; // 일시정지 여부
  DateTime? _startTime; // 녹음 시작 시간
  Duration _pausedDuration = Duration.zero; // 일시정지된 시간 누적
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Nothing Recorded';

  String summaryText = "요약 결과가 여기에 표시됩니다.";

  Future<void> summarizeText(String text) async {
    final url = Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/text-summary/v1/summarize');

    // 네이버 API 키와 시크릿
    const String clientId = ''; // 본인의 Client ID 입력
    const String clientSecret = ''; // 본인의 Client Secret 입력

    // 요청 헤더 설정
    final headers = {
      'Content-Type': 'application/json',
      'X-NCP-APIGW-API-KEY-ID': clientId,
      'X-NCP-APIGW-API-KEY': clientSecret,
    };

    // 요청 바디 설정
    final body = jsonEncode({
      'document': {
        'content': text,
      },
      'option': {
        'language': 'ko',
        'model': 'general',
        'tone': 2,
        'summaryCount': 3,
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedBody);

        // 요약 텍스트를 상태에 저장하여 UI 갱신
        setState(() {
          summaryText = responseData['summary'];
        });
      } else {
        setState(() {
          summaryText = "요약에 실패했습니다. (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        summaryText = "오류가 발생했습니다: $e";
      });
    }
  }

  Future<void> _initializePlayer() async {
    await _controller.preparePlayer(
      path: 'assets/mp3/noti', // 오디오 파일 경로 설정
      shouldExtractWaveform: true,
      noOfSamples: 100,
    );

    _totalDuration =
        await _controller.getDuration(DurationType.max) ?? 0; // 총 길이 설정

    // 재생 시간 변화 리스너
    _controller.onCurrentDurationChanged.listen((duration) {
      setState(() {
        _currentDuration = duration;
      });
    });

    // 재생 완료 리스너
    _controller.onCompletion.listen((_) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentDuration = 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    //controller = RecorderController();
    _speech = stt.SpeechToText();
    _initializePlayer();
  }

  @override
  void dispose() {
    //controller.dispose();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      if (_isPaused) {
        await _controller.startPlayer();
      } else {
        await _controller.pausePlayer();
      }
    } else {
      await _controller.startPlayer();
    }
    setState(() {
      _isPlaying = !_isPlaying;
      _isPaused = !_isPaused;
    });
  }

  void _startTimer() {
    _startTime ??= DateTime.now(); // 녹음 시작 시간 설정
    _timer?.cancel(); // 기존 타이머 취소
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        // 시작 시간과 현재 시간의 차이에서 일시정지 시간 누적 값을 뺌
        recordingDuration =
            DateTime.now().difference(_startTime!) - _pausedDuration;
      });
    });
  }

  void _pauseTimer() {
    _pausedDuration += DateTime.now().difference(_startTime!);
    _timer?.cancel(); // 타이머 일시정지
    setState(() {
      isPaused = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTime = null;
    _pausedDuration = Duration.zero;
    setState(() {
      recordingDuration = Duration.zero;
      isPaused = false;
    });
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
          localeId: 'ko_KR',
        );
      }

      await _controller.startPlayer(finishMode: FinishMode.stop);

      _resetTimer();
      _startTimer();
      setState(() {
        isRecording = true;
        isPaused = false;
      });

    } else {
      setState(() => _isListening = false);
      _speech.stop();

      _pauseTimer();
      setState(() {
        isRecording = false;
      });
      _showFullScreenDialog(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 오디오 파형
              AudioFileWaveforms(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                //recorderController: controller,
                playerController: _controller,
                playerWaveStyle: PlayerWaveStyle(
                  liveWaveColor: Colors.deepPurple,
                  showSeekLine: false,
                  spacing: 10.0,
                  showBottom: true,
                  waveThickness: 4.0,
                  scaleFactor: 150.0,
                  liveWaveGradient: ui.Gradient.linear(
                    const Offset(70, 50),
                    Offset(constraints.maxWidth / 2, 0),
                    [Colors.red, Colors.green],
                  ),
                ),
              ),
              // 녹음 시간 표시 (화면 상단)
              Positioned(
                top: 10,
                child: Text(
                  _formatDuration(recordingDuration),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // 중앙 하단에 시작 및 정지 버튼
              Positioned(
                bottom: 16,
                child: Container(
                  width: 60, // 원형의 지름
                  height: 60, // 원형의 지름
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경 색상
                    shape: BoxShape.circle, // 원형 모양
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2), // 그림자 색상
                        blurRadius: 1.0, // 그림자 퍼짐 정도
                        spreadRadius: 1.5, // 그림자 확산 정도
                        offset: const Offset(0, 0), // 그림자의 위치 (X, Y 축)
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _listen();
                        //controller.record();
                      },
                      child: Icon(
                        _isListening ? Icons.stop : Icons.play_arrow,
                        size: 32, // 아이콘 크기
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 녹음 시간을 분:초:밀리초 형식으로 변환
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = twoDigits(
        (duration.inMilliseconds % 1000) ~/ 10);

    return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }

  void _showFullScreenDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white.withOpacity(0.8), // 반투명 배경
          body: Stack(
            children: [
              Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child:  Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8), // 둥근 모서리

                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.6), // 그림자 색상과 투명도
                                spreadRadius: 1.5, // 그림자 퍼짐 정도
                                blurRadius: 1.5,  // 그림자 흐림 정도
                                offset: Offset(0, 0), // 그림자 위치 (x, y)
                              ),
                            ],
                          ),
                          child:  Center(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '      김옥자(64세, 여성)',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25), // 둥근 모서리
                                  borderSide: BorderSide.none, // 외곽선 제거
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              _text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              summaryText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: FloatingActionButton(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  onPressed: () async { summarizeText(_text); },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}