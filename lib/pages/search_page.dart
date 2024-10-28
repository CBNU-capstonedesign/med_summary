import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


// Search 페이지 클래스
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> patients = [];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Center(
              child: SearchBar(
                trailing: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      print('search');
                    },
                  ),
                ],
                hintText: "환자 이름을 입력하세요",
              ),
            ),
          ),
        ),
        Flexible(
          flex: 8,
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
      ],
    );
  }
}