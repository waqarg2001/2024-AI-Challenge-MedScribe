import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({
    super.key,
    required this.patientCode,
    required this.authToken,
  });

  final String patientCode;
  final String authToken;

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  Future<dynamic> getHistoryRecords() async {
    // Fetch patient records from the database
    try {
      var dio = Dio();
      var response = await dio.get(
        '${MedScribeBackenAPI().baseURL}/visitHistory/${widget.patientCode}',
        options: Options(headers: {
          'authorization': 'token ${widget.authToken}',
        }),
      );
      var records = response.data['result'];
      for (var record in records) {
        // Fetch additional data for each record
        var doctorResponse = await dio.get(
          '${MedScribeBackenAPI().baseURL}/doctor/${record['doctor_code']}',
          options: Options(headers: {
            'authorization': 'token ${widget.authToken}',
          }),
        );
        record['doctor_data'] = doctorResponse.data;
        print('Doctor Data: ${record['doctor_data']}');

        if (record['notes_id'] != null) {
          var imageResponse = await dio.get(
            '${MedScribeBackenAPI().baseURL}/clinicalNotes/${record['notes_id']}',
            options: Options(headers: {
              'authorization': 'token ${widget.authToken}',
            }),
          );
          record['notes_id'] = imageResponse.data;
        }
      }

      return records;
    } catch (e) {
      print('Error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            // Year by Record filter,
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      width: 1.0,
                      color: MedScribe_Theme.secondary_color,
                    ),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    "All Records",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: MedScribe_Theme.secondary_color,
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: FutureBuilder(
                future: getHistoryRecords(),
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

                  if (snapshot.hasData) {
                    var records = snapshot.data;
                    print('Records: $records');
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        DateTime visitDate =
                            DateTime.parse(records[index]['visit_date']);
                        String formattedDate =
                            DateFormat('MMMM dd, yyyy').format(visitDate);
                        String formattedTime =
                            DateFormat('h:mm a').format(visitDate);

                        String type_of_pain =
                            records[index]['notes_id']['type_of_pain'];

                        return MedScribe_Widgets.patient_record_card(
                          context: context,
                          imagePath: getSpecialityIconPath(records[index]
                                  ['doctor_data']['doctorResult'][0]
                              ['area_of_experties']),
                          date: formattedDate,
                          diagnosis: type_of_pain,
                          title: records[index]['doctor_data']['doctorResult']
                              [0]['area_of_experties'],
                          time: formattedTime,
                          attendingDoctor: records[index]['doctor_data']
                              ['doctorResult'][0]['doctor_name'],
                          onTap: () {
                            // Get.toNamed('/transcribe_screen');
                            //Transcription Screen
                          },
                        );
                      },
                    );
                  }
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
