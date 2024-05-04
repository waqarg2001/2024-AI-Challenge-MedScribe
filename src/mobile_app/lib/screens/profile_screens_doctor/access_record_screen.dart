import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/widgets.dart';

class AccessRecordScreen extends StatefulWidget {
  const AccessRecordScreen(
      {super.key,
      required this.onQRButtonPressed,
      required this.onCodeButtonPressed});

  final Function onQRButtonPressed;
  final Function onCodeButtonPressed;

  @override
  State<AccessRecordScreen> createState() => _AccessRecordScreenState();
}

class _AccessRecordScreenState extends State<AccessRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.1,
            ),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "Access patient record",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF777779),
                  ),
                ),
                TextSpan(
                    text:
                        "\nTo access or add a new record to patient's history, scan their QR code or enter code.",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777779),
                    ))
              ]),
            ),
          ),
          MedScribe_Widgets.doctorMainScreenButtonV1(
            context: context,
            onTap: () {
              widget.onQRButtonPressed();
            },
            text: "Scan QR Code",
          ),
          MedScribe_Widgets.or_text_widget(context: context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          MedScribe_Widgets.doctorMainScreenButtonV1(
            context: context,
            onTap: () {
              widget.onCodeButtonPressed();
            },
            text: "Enter Code",
          ),
        ],
      ),
    );
  }
}
