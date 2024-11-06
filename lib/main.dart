import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/notify_page.dart';
import 'pages/setting_page.dart';
import 'pages/account.dart';
import 'pages/record.dart';

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
    const RecordPage(),
    const SearchPage(),
    NotifyPage(),
    const SettingPage(),
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isAccountPage = false;
      Navigator.pop(context); // 드로어 닫기
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outlined, color: Color(0xff004f2d)),
            SizedBox(width: 4),
            Text(
              'MEDISUM',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                setState(() {
                  _isAccountPage = true;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 0),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_voice_outlined),
              title: const Text('Record'),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.search_outlined),
              title: const Text('Search'),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Alarm'),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => _onDrawerItemTapped(4),
            ),
          ],
        ),
      ),
      body: Center(
        child: _isAccountPage
            ? const AccountPage()
            : _selectedIndex == -1
            ? const Text('Please select a page')
            : _pages.elementAt(_selectedIndex),
      ),
    );
  }

  Widget _buildProfileImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.account_circle_outlined,
        size: 24.0,
        color: Colors.grey,
      );
    } else {
      return ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 24.0,
          height: 24.0,
        ),
      );
    }
  }
}
