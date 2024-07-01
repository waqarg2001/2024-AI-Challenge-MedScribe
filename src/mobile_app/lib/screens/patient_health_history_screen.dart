import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientHealthHistory extends StatefulWidget {
  const PatientHealthHistory(
      {super.key,
      required this.patientCode,
      required this.doctorCode,
      required this.authToken});
  final String patientCode;
  final String doctorCode;
  final String authToken;

  @override
  State<PatientHealthHistory> createState() => _PatientHealthHistoryState();
}

class _PatientHealthHistoryState extends State<PatientHealthHistory> {
  final dateFilter = [
    {'value': 'All Records', 'selected': true},
    {'value': '2024', 'selected': false},
    {'value': '2023', 'selected': false},
    {'value': '2022', 'selected': false},
    {'value': '2021', 'selected': false},
    {'value': '2020', 'selected': false},
  ];

  late Future<List<dynamic>> _futureRecords;

  Future<List<dynamic>> _fetchRecords(
      {bool forceUpdate = false, String? year}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedRecords =
        prefs.getString('health_history_records_${widget.patientCode}');

    if (!forceUpdate && storedRecords != null) {
      return jsonDecode(storedRecords);
    } else {
      try {
        var response = await http.get(
          Uri.parse(
              '${MedScribeBackenAPI().baseURL}/visitHistory/${widget.patientCode}/${year ?? ""}'),
          headers: {
            'authorization': 'token ${widget.authToken}',
          },
        );
        var records = jsonDecode(response.body)['result'];
        for (var record in records) {
          if (record['notes_id'] != null) {
            var imageResponse = await http.get(
              Uri.parse(
                  '${MedScribeBackenAPI().baseURL}/clinicalNotes/${record['notes_id']}'),
              headers: {
                'authorization': 'token ${widget.authToken}',
              },
            );
            record['notes_id'] = jsonDecode(imageResponse.body);
          }
        }

        await prefs.setString('health_history_records_${widget.patientCode}',
            jsonEncode(records));
        return records;
      } catch (e) {
        print('Error: $e');
        throw Exception('Failed to fetch records');
      }
    }
  }

  String getSpecialityIconPath(String speciality) {
    if (speciality == 'Cardiologist') {
      return "assets/cardio.png";
    } else if (speciality == 'ENT Specialist') {
      return "assets/ent.png";
    }
    return "assets/general_physicist.png";
  }

  Future<void> _refreshRecords({String? year}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('health_history_records_${widget.patientCode}');
    setState(() {
      _futureRecords = _fetchRecords(forceUpdate: true, year: year);
    });
  }

  @override
  void initState() {
    print('Patient Code: ${widget.patientCode}');
    print('Doctor Code: ${widget.doctorCode}');
    super.initState();
    _futureRecords = _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 6.0,
            ),
            // Year by Record filter;
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: dateFilter.map((dateMap) {
                    return GestureDetector(
                      onTap: () {
                        // Filter records by year
                        _refreshRecords(
                            year: dateMap['value'] == 'All Records'
                                ? null
                                : dateMap['value'].toString());
                        setState(() {
                          dateFilter.forEach((item) {
                            item['selected'] = (item == dateMap);
                          });
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.3,
                        margin: EdgeInsets.only(right: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            width: 1.0,
                            color: MedScribe_Theme.secondary_color,
                          ),
                          color: (dateMap['selected'] == true)
                              ? MedScribe_Theme.secondary_color
                              : MedScribe_Theme.white,
                        ),
                        child: Text(
                          dateMap['value'].toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: (dateMap['selected'] == true)
                                ? MedScribe_Theme.white
                                : MedScribe_Theme.secondary_color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureRecords,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    var records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        DateTime visitDate =
                            DateTime.parse(records[index]['visit_date']);
                        String formattedDate =
                            DateFormat('MMMM dd, yyyy').format(visitDate);
                        String formattedTime =
                            DateFormat('h:mm a').format(visitDate);

                        // Example: Accessing nested JSON
                        String type_of_pain =
                            records[index]['notes_id']['type_of_pain'] ?? "";

                        return MedScribe_Widgets.patient_record_card(
                          context: context,
                          imagePath: records[index]['area_of_experties'] == null
                              ? "assets/general_physicist.png"
                              : getSpecialityIconPath(
                                  records[index]['area_of_experties']),
                          date: formattedDate,
                          diagnosis:
                              type_of_pain, // Modify as per your data structure
                          title: records[index]['area_of_experties'] == null
                              ? "General Physicist"
                              : records[index]['area_of_experties'],
                          time: formattedTime,
                          attendingDoctor: records[index]['doctor_name'] == null
                              ? ""
                              : records[index]['doctor_name'],
                          onTap: () {
                            // Get.toNamed('/transcribe_screen', arguments: {
                            //   'record': records[index],
                            //   'authToken': widget.authToken,
                            //   'patientCode': widget.patientCode,
                            // });
                          },
                        );
                      },
                    );
                  }

                  // If no data, show a message
                  return Center(
                    child: Text('No records found'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
