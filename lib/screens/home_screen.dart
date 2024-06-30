import 'package:flutter/material.dart';
import 'recording_screen.dart';  // RecordingScreen을 가져옵니다.

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('응급실 환자 관리'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientDetailsScreen()),
                );
              },
              child: Text('환자 정보 보기'),
            ),
            */
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 24), 
              ),
              child: Text('처치 기록 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
