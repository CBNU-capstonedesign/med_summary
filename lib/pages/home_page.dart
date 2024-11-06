import 'package:flutter/material.dart';
import 'notify_page.dart'; // NotiPage를 불러오기
import 'record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: RecordPage(),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 2,
                            offset: Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: NotifyPage(),
                      ),
                    ),
                ),
            ),
          ]
      ),
    );
  }
}
