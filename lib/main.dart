import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'pages/firebase_options.dart';

import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/notify_page.dart';
import 'pages/setting_page.dart';
import 'pages/account.dart';




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _isAccountPage = false;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const SearchPage(),
    NotifyPage(),
    const SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isAccountPage = false;
    });
  }

  //상단바 및 네비게이션바
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min, // 아이콘과 텍스트의 크기에 맞춰 최소 크기로 설정
          children: [
            Icon(Icons.add_circle_outlined,
                color: Color(
                    0xff004f2d
                )), // 원하는 아이콘 설정
            SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격 설정 (필요에 따라 조절 가능)
            Text(
              'MEDISUM',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        centerTitle: false,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16), // 우측 간격 조정
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                setState(() {
                  _isAccountPage = true;
                });
              },
              child: Container(
                width: 24, // Text의 크기와 동일한 너비 (텍스트가 보통 24dp 정도)
                height: 24, // Text의 크기와 동일한 높이
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  // 원형 모양으로 설정
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 0), // 그림자 위치
                    ),
                  ],
                ),

                child: ClipOval(
                  child: _buildProfileImage(""),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _isAccountPage
            ? const AccountPage()
            : _selectedIndex == -1
            ? const Text('Please select a page')
            : _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'setting',
          ),
        ],
        currentIndex: _selectedIndex >= 0 ? _selectedIndex : 0,
        selectedItemColor: _isAccountPage ? Colors.purple : Colors.deepPurple,
        unselectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
  Widget _buildProfileImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.account_circle_outlined,
        size: 24.0, // 아이콘 크기
        color: Colors.grey, // 아이콘 색상
      );
    } else {
      return ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 24.0, // 이미지 크기
          height: 24.0,
        ),
      );
    }
  }
}