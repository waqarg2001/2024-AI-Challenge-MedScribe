import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class DocterProfileScreen extends StatefulWidget {
  DocterProfileScreen(
      {super.key,
      required this.gender,
      required this.birth_date,
      required this.cnic,
      required this.email,
      required this.phone,
      required this.city,
      required this.hospital});

  final String gender;
  final String birth_date;
  final String cnic;
  final String email;
  final String phone;
  final String city;
  final String hospital;

  @override
  State<DocterProfileScreen> createState() => _DocterProfileScreenState();
}

class _DocterProfileScreenState extends State<DocterProfileScreen> {
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
          child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Table(
              children: [
                TableRow(
                  children: [
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
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "Date of birth:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.birth_date)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "CNIC:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.cnic)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "Email:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.email)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "Phone No:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.phone)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "City:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.city)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: "Current Hospital:")),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.01),
                        child: MedScribe_Widgets.profile_screen_details_value(
                            context: context, value: widget.hospital)),
                  ],
                ),
              ],
            ),
            // Row(children: [
            //   MedScribe_Widgets.profile_screen_details_key(
            //     context: context,
            //     key1: "Gender:",
            //     key2: "Date of birth:",
            //     key3: "CNIC:",
            //     key4: "Email:",
            //     key5: "Phone No:",
            //     key6: "City:",
            //     key7: "Current Hospital:",
            //     topMargin: false,
            //   ),
            //   SizedBox(
            //     width: MediaQuery.of(context).size.width * 0.05,
            //   ),
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.gender),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.birth_date),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.cnic),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.email),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.phone),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.city),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //       MedScribe_Widgets.profile_screen_details_value(
            //           context: context, value: widget.hospital),
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.02,
            //       ),
            //     ],
            //   )
            // ]),
          ),
        )
      ]),
    );
  }
}
