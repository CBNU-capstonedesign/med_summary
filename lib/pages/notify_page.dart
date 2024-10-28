import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


// NOTIFY 페이지 클래스
class NotifyPage extends StatefulWidget {
  NotifyPage({super.key});
  @override
  _NotifyPageState createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {

  @override
  void initState() {
    super.initState();
    _fetchAllPatients();
  }

  Future<void> _fetchAllPatients() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Patient').get();

      setState(() {
        patients = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // 'id' 필드를 기준으로 내림차순으로 정렬
        patients.sort((a, b) => b['id'].compareTo(a['id']));
      });
    } catch (e) {
      setState(() {
        patients = [];
      });
      print('Error fetching data: $e');
    }
  }

  int _calculateAge(Timestamp birthdate) {
    DateTime birthDate = birthdate.toDate(); // Convert Firestore Timestamp to DateTime
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // If the birthday hasn't occurred yet this year, subtract 1 from the age
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  String _getGender(bool gender) {
    return gender ? '남성' : '여성';
  }

  final List<Map<String, dynamic>> announcement = [
    {
      'title': '서비스 점검 안내',
      'content':
      '안녕하세요, 시스템 안정화를 위해 2024년 10월 20일(일) 오전 2시부터 4시까지 정기 점검을 진행할 예정입니다. 점검 시간 동안 서비스 이용이 제한될 수 있으니 양해 부탁드립니다.'
    },
    {
      'title': '새로운 기능 업데이트',
      'content':
      '앱에 새로운 기능이 업데이트되었습니다! 이제 푸시 알림을 통해 실시간으로 중요한 소식을 빠르게 확인할 수 있습니다. 설정에서 알림 수신을 활성화해보세요.'
    },
    {
      'title': '보안 강화 알림',
      'content':
      '안전한 서비스 이용을 위해 2단계 인증(2FA)을 도입하였습니다. 설정에서 2단계 인증을 활성화하여 계정 보안을 강화하세요.'
    },
    {
      'title': '정책 변경 안내',
      'content':
      '서비스 이용 약관이 2024년 11월 1일부터 개정됩니다. 변경된 약관은 개인정보 보호 및 서비스 향상에 관한 내용을 포함하고 있습니다. 개정된 내용을 반드시 확인해주세요.'
    },
    {
      'title': '이벤트 참여 안내',
      'content':
      '가을 맞이 특별 이벤트! 지금 참여하고 다양한 혜택을 받아보세요. 참여 기간: 2024년 10월 15일 ~ 2024년 10월 31일. 자세한 내용은 이벤트 페이지에서 확인하세요.'
    },
  ];

  List<Map<String, dynamic>> patients = [];

  final List<Map<String, dynamic>> notice = [
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': '응급실 접수 완료',
      'content': '64세 여성 김옥자 님이 응급실에 접수되었습니다. 현재 의료진이 초기 진료를 진행하고 있습니다.'
    },
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': '응급 상태 진단 중',
      'content': '김옥자 님의 상태를 진단 중입니다. 혈압, 체온, 심박수 등 주요 생체 징후를 측정하고 있습니다.'
    },
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': '응급 처치 진행',
      'content': '김옥자 님에게 즉각적인 응급 처치가 진행되었습니다. 안정화를 위한 조치가 완료되었으며, 추가 검사 및 치료가 필요합니다.'
    },
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': 'CT 촬영 예정',
      'content': '김옥자 님의 정확한 진단을 위해 CT 촬영이 예정되어 있습니다. 검사 결과에 따라 추가적인 치료 계획이 결정됩니다.'
    },
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': '보호자 안내',
      'content': '김옥자 님의 보호자께서는 안내 데스크로 와주시기 바랍니다. 환자의 상태와 이후 진료 일정에 대해 설명드리겠습니다.'
    },
    {
      'name': '김옥자',
      'age': 64,
      'gender': '여성',
      'title': '입원 결정',
      'content': '김옥자 님의 상태를 고려하여 입원이 결정되었습니다. 병동으로 이동 후 지속적인 치료와 관찰이 진행될 예정입니다.'
    },
  ];


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,  // 탭의 개수 설정
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: '노티'),
            Tab(text: '신규'),
            Tab(text: '공지'),
          ],
        ),
        body: TabBarView(
          children: [
            Center(child: ListView.separated(
              itemCount: notice.length,
              itemBuilder: (context, index) {
                var item = notice[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${item['name']} (${item['age']}세, ${item['gender']})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0), // 내용과 제목 사이의 간격
                        Text(item['content']),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(); // 리스트 항목 사이의 구분선
              },
            )
            ),
            Center(
              child: patients.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  var patient = patients[index];
                  var birthdate = patient['birthdate'] as Timestamp?;
                  var gender = patient['gender'] as bool?; // Assuming gender is a boolean value

                  // Calculate age if birthdate exists
                  int age = birthdate != null ? _calculateAge(birthdate) : 0;

                  // Get gender string
                  String genderString = gender != null ? _getGender(gender) : 'Unknown';

                  return ListTile(
                    title: Text(patient['name'] ?? 'No Name'),
                    subtitle: Text('나이: $age\n성별: $genderString'), // Display calculated age and gender
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(); // 리스트 항목 사이에 선을 추가
                },
              ),
            ),
            Center(child: ListView.separated(
              itemCount: announcement.length,
              itemBuilder: (context, index) {
                var item = announcement[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16.0), // 아이콘과 텍스트 사이의 간격
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8.0),
                            Text(item['content']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(); // 리스트 항목 사이의 선
              },
            ),
            ),
          ],
        ),
      ),
    );
  }
}