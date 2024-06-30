import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('환자 정보'),
      ),
      body: Center(
        child: Text('환자 정보 상세 화면'),
      ),
    );
  }
}
