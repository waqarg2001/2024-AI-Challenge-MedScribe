import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class MedicalProfile extends StatefulWidget {
  const MedicalProfile({
    super.key,
    required this.fatherName,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.maritalStatus,
    required this.height,
    required this.weight,
    required this.bp,
    required this.pulse,
  });
  final String fatherName;
  final String gender;
  final String dob;
  final String bloodGroup;
  final String maritalStatus;
  final String height;
  final String weight;
  final String bp;
  final String pulse;
  @override
  State<MedicalProfile> createState() => _MedicalProfileState();
}

class _MedicalProfileState extends State<MedicalProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.02),
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05),
            alignment: Alignment.bottomRight,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height * 0.04,
              decoration: BoxDecoration(
                color: MedScribe_Theme.secondary_color,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Text(
                textAlign: TextAlign.center,
                "View PDF",
                style: GoogleFonts.inter(
                  color: MedScribe_Theme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.20,
          child: Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Table(children: [
                TableRow(children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: "Father's name:")),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: widget.fatherName)),
                ]),
                TableRow(children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: "Gender:")),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: widget.gender)),
                ]),
                TableRow(children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: "Date of birth:")),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: widget.dob)),
                ]),
                TableRow(children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: "Blood group:")),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: widget.bloodGroup)),
                ]),
                TableRow(children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: "Marital status:")),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: MedScribe_Widgets.profile_screen_details_value(
                          context: context, value: widget.maritalStatus)),
                ]),
              ])),
        ),
        Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.03,
                bottom: MediaQuery.of(context).size.height * 0.02),
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.02,
            ),
            child: MedScribe_Widgets.underline()),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.20,
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MedScribe_Widgets.profile_screen_health_details(
                        context: context,
                        key: "Height:",
                        value:
                            "${(double.parse(widget.height) * 0.393701) ~/ 12}' ${((double.parse(widget.height) * 0.393701) % 12).toStringAsFixed(0)}''"),
                    MedScribe_Widgets.profile_screen_health_details(
                        context: context,
                        key: "Weight(kg):",
                        value: widget.weight),
                    MedScribe_Widgets.profile_screen_health_details(
                      context: context,
                      key: "BMI:",
                      value: (double.parse(widget.weight) /
                              (double.parse(widget.height) *
                                  double.parse(widget.height) /
                                  10000))
                          .toStringAsFixed(2),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MedScribe_Widgets.profile_screen_health_details(
                        context: context,
                        key: "BP(last rec):",
                        value: widget.bp),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    MedScribe_Widgets.profile_screen_health_details(
                        context: context,
                        key: "Pulse/min:",
                        value: widget.pulse),
                    Expanded(
                      child: SizedBox(),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
