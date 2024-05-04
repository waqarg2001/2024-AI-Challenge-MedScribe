import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'themes.dart';

class MedScribe_Widgets {
  static Widget underline() {
    return Container(
        height: 1.0,
        decoration: BoxDecoration(
          color: Color(0xFFB6B6B6),
          borderRadius: BorderRadius.circular(10.0),
        ));
  }

  static Widget calendar_field({
    required String text,
    required String iconPath,
    required Function() onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 35, child: Center(child: Image.asset(iconPath))),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.04),
                child: Text(
                  textAlign: TextAlign.left,
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF595959),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget text_field({
    required TextEditingController controller,
    required String hintText,
    required String prefixIconPath,
    required TextInputType keyboardType,
    required double prefixIconWidth,
  }) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Color(0xFF595959),
          fontWeight: FontWeight.w600,
        ),
        icon: Container(
          width: prefixIconWidth,
          child: Center(child: Image.asset(prefixIconPath)),
        ),
      ),
    );
  }

  static Widget login_button({
    required double width,
    required double height,
    required String text,
    required Color buttonColor,
    required bool active,
    required Color textColor,
  }) {
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: active ? buttonColor : buttonColor.withOpacity(0.7),
        gradient: !active
            ? LinearGradient(colors: [
                Color(0xFFFF9B63),
                Color(0xFFFF621F),
              ])
            : LinearGradient(colors: [Colors.white, Colors.white]),
      ),
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget report_button({
    required double width,
    required double height,
    required String text,
    required Color buttonColor,
    required bool active,
    required Color textColor,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: active ? buttonColor : Color(0xffBEB9B9),
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget or_text_widget({required BuildContext context}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: MedScribe_Widgets.underline(),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              "OR",
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: MedScribe_Widgets.underline(),
          ),
        ],
      ),
    );
  }

  static Widget check_button({required bool ischecked}) {
    return Container(
      padding: EdgeInsets.all(3.0),
      margin: EdgeInsets.only(right: 10.0),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(
          color: ischecked ? MedScribe_Theme.secondary_color : Colors.black,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        width: 16,
        height: 16,
        color: ischecked ? MedScribe_Theme.secondary_color : Colors.white,
      ),
    );
  }

  static Widget login_signup_Swicther(
      {required String text1, required String text2}) {
    return Text.rich(
      TextSpan(
          text: "$text1 ",
          style: TextStyle(
            fontSize: 9.0,
            color: MedScribe_Theme.black,
          ),
          children: [
            TextSpan(
              text: text2,
              style: TextStyle(
                fontSize: 9.0,
                color: MedScribe_Theme.secondary_color,
                fontWeight: FontWeight.w900,
              ),
            )
          ]),
    );
  }

  static Widget conditions_text() {
    return const Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: "By checking the box you agree to our ",
        style: TextStyle(
          fontSize: 9.0,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: "Terms ",
            style: TextStyle(
              fontSize: 9.0,
              color: MedScribe_Theme.secondary_color,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "and ",
            style: TextStyle(
              fontSize: 9.0,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "Conditions",
            style: TextStyle(
              fontSize: 10.0,
              color: MedScribe_Theme.secondary_color,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ".",
            style: TextStyle(
              fontSize: 9.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget google_button({
    required double width,
    required String text1,
    required double height,
    required Color backColor,
    required String iconPath,
    required double radius,
    required bool shadow,
    double? iconWidth,
    double? iconHeight,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      height: height,
      width: width * 0.80,
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (shadow)
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.only(
                left: width * 0.1,
                right: width * 0.1,
              ),
              child: Image.asset(
                iconPath,
                width: iconHeight ?? 25,
                height: iconWidth ?? 25,
                color: iconColor ?? Colors.black,
              )),
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              textAlign: TextAlign.left,
              text1,
              style: GoogleFonts.inter(
                color: textColor ?? Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ))
        ],
      ),
    );
  }

  static Widget navigation_item(
      {required String text,
      required String imagePath,
      required bool active,
      required BuildContext context}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            width: MediaQuery.of(context).size.width * 0.15,
            imagePath,
            color:
                active ? MedScribe_Theme.secondary_color : MedScribe_Theme.grey,
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: active
                  ? MedScribe_Theme.secondary_color
                  : MedScribe_Theme.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static Widget profile_screen_details_value(
      {required String value, required BuildContext context}) {
    double fontSize = MediaQuery.of(context).size.width * 0.040;
    if (value.length > 15) {
      fontSize = MediaQuery.of(context).size.width * 0.035;
    }
    return Text(
      value,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: MedScribe_Theme.black,
      ),
    );
  }

  static Widget patient_record_card(
      {required BuildContext context,
      required String imagePath,
      required String date,
      required String diagnosis,
      required String title,
      required String time,
      required String attendingDoctor,
      required Function onTap}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
        ),
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.0,
            color: MedScribe_Theme.secondary_color,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              height: MediaQuery.of(context).size.height * 0.09,
              decoration: BoxDecoration(
                color: MedScribe_Theme.secondary_color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    child: Image.asset(
                      imagePath,
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                  ),
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          color: Color(0xFFF6F6FC),
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: Color(0xFFF6F6FC),
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.015,
                    ),
                    child: Text(
                      diagnosis,
                      style: GoogleFonts.inter(
                        color: Color(0xFF777779),
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                  ),
                  Text(
                    "Time: $time",
                    style: GoogleFonts.inter(
                      color: Color(0xFFA8A8A9),
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  Text("Attending Doctor: $attendingDoctor",
                      style: GoogleFonts.inter(
                        color: Color(0xFFA8A8A9),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget profile_screen_health_details(
      {required String key,
      required String value,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          textAlign: TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.secondary_color,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w400,
            color: MedScribe_Theme.black,
          ),
        ),
      ],
    );
  }

  static Widget profile_screen_details_key(
      {required String key1,
      required String key2,
      required String key3,
      required String key4,
      required String key5,
      bool topMargin = true,
      String key6 = "",
      String key7 = "",
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (topMargin)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
        Text(
          key1,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.040,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.black,
          ),
        ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          key2,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.040,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.black,
          ),
        ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          key3,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.040,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.black,
          ),
        ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          key4,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.040,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.black,
          ),
        ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          key5,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.040,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.black,
          ),
        ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        if (key6 != "")
          Text(
            key6,
            style: GoogleFonts.inter(
              fontSize: MediaQuery.of(context).size.width * 0.040,
              fontWeight: FontWeight.w600,
              color: MedScribe_Theme.black,
            ),
          ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
        if (key7 != "")
          Text(
            key7,
            style: GoogleFonts.inter(
              fontSize: MediaQuery.of(context).size.width * 0.040,
              fontWeight: FontWeight.w600,
              color: MedScribe_Theme.black,
            ),
          ),
        SizedBox(
          height: topMargin ? 0.0 : MediaQuery.of(context).size.height * 0.02,
        ),
      ],
    );
  }

  static Widget setting_screen_button(
      {required BuildContext context,
      required Function onTap,
      required String buttonText,
      required String buttonIconPath}) {
    return GestureDetector(
      onTap: () {
        //Patient Code Button
        onTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(
          color: MedScribe_Theme.secondary_color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Image.asset(
                buttonIconPath,
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.06,
              ),
            ),
            Expanded(
              child: Text(
                textAlign: TextAlign.left,
                buttonText,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  color: MedScribe_Theme.white,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Image.asset("assets/right_arrow.png"),
            ),
          ],
        ),
      ),
    );
  }

  static Widget transcribe_buttons({
    required BuildContext context,
    required String buttonText,
    required String buttonIconPath,
    required AnimationController controller,
    required Function() onTap,
    required bool active,
    required double initialPosition,
    required Widget AnimatedContainer,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        controller.forward(from: 0.0);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: MedScribe_Theme.secondary_color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Image.asset(
                      buttonIconPath,
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.left,
                      buttonText,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        color: MedScribe_Theme.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.04,
                    ),
                    child: RotationTransition(
                      turns: active
                          ? Tween(begin: 0.0, end: 0.50).animate(controller)
                          : Tween(begin: initialPosition, end: 0.0)
                              .animate(controller),
                      child: Image.asset(
                        "assets/top_arrow.png",
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer,
          ],
        ),
      ),
    );
  }

  static Widget main_screen_appbar({
    required BuildContext context,
    required String itemImagePath,
    required String titleText,
    required String patientName,
    required String patientAge,
    required String lastVisitDate,
    required String profileImagePath,
    required bool showProfile,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: showProfile
          ? MediaQuery.of(context).size.height * 0.27
          : MediaQuery.of(context).size.height * 0.13,
      child: showProfile
          ? Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                  ),
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: BoxDecoration(
                    color: MedScribe_Theme.secondary_color,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          itemImagePath,
                        ),
                        Text(titleText,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: MedScribe_Theme.white,
                            )),
                      ]),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: 12,
                  right: 12,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text(
                                patientName,
                                style: MedScribe_Theme.main_title_text_style,
                              ),
                              Text(
                                patientAge,
                                style: MedScribe_Theme.main_desc_text_style,
                              ),
                            ],
                          ),
                        ),
                        ClipOval(
                          child: Image.network(
                            profileImagePath,
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.height * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                "Last Visit",
                                style: MedScribe_Theme.main_title_text_style,
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                lastVisitDate,
                                style: MedScribe_Theme.main_desc_text_style,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                color: MedScribe_Theme.secondary_color,
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  itemImagePath,
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Text(titleText,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: MedScribe_Theme.white,
                    )),
              ]),
            ),
    );
  }

  static Widget doctor_main_screen_appbar({
    required BuildContext context,
    required String itemImagePath,
    required String titleText,
    String? DoctorName,
    String? DoctorSpeciality,
    String? profileImagePath,
    required bool showProfile,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: showProfile
          ? MediaQuery.of(context).size.height * 0.27
          : MediaQuery.of(context).size.height * 0.13,
      child: showProfile
          ? Stack(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: BoxDecoration(
                    color: MedScribe_Theme.secondary_color,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          itemImagePath,
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        Text(titleText,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: MedScribe_Theme.white,
                            )),
                      ]),
                ),
                Container(
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.08,
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Dr ${DoctorName!.replaceAll(' ', '\n')}",
                                  style: MedScribe_Theme.main_title_text_style,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  DoctorSpeciality!.replaceAll(' ', '\n'),
                                  style: MedScribe_Theme.main_title_text_style,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.12,
                        left: MediaQuery.of(context).size.width * 0.33,
                        child: ClipOval(
                          child: Image.network(
                            profileImagePath!,
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.height * 0.15,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                color: MedScribe_Theme.secondary_color,
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  itemImagePath,
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Text(titleText,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: MedScribe_Theme.white,
                    )),
              ]),
            ),
    );
  }

  static Widget main_screen_appbar_shimmer({
    required BuildContext context,
    bool showProfile = false,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: showProfile
            ? MediaQuery.of(context).size.height * 0.27
            : MediaQuery.of(context).size.height * 0.13,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
              ),
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.20,
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              left: 12,
              right: 12,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    showProfile
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            width: MediaQuery.of(context).size.height * 0.15,
                            height: MediaQuery.of(context).size.height * 0.15,
                          )
                        : Container(),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget login_Switcher({
    required BuildContext context,
    required String text,
    required bool selected,
    required double fontSize,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        key: Key(selected.toString()),
        duration: Duration(milliseconds: 2500),
        child: Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.017,
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.40,
          height: MediaQuery.of(context).size.height * 0.058,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: selected ? Color(0xFFFFFFFF) : Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: selected
                    ? Color(0xFF00000040).withOpacity(0.25)
                    : Colors.transparent,
                spreadRadius: 0,
                blurRadius: 7,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }

  static Widget onboarding_button({
    required String text,
    required String routePath,
    required String routeParam,
    required Color textColor,
    required Color backgroundColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routePath, parameters: {'routeType': routeParam});
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: backgroundColor,
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget account_type_button({
    required BuildContext context,
    required String text,
    required String imagePath,
    required Function() onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.50,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border.all(
            color: active
                ? Color(0xFFFF9157)
                : Color(0xFF1616162B).withOpacity(0.17),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            Text(
              textAlign: TextAlign.center,
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget route_param_button(
      {required String text,
      required String routePath,
      required Color textColor,
      required String paramKey,
      required String paramValue,
      required Color backgroundColor,
      required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routePath, parameters: {paramKey: paramValue});
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: backgroundColor,
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget button_widget(
      {required double width,
      required bool enable,
      required String text,
      required String iconPath,
      double? height}) {
    return Container(
      width: width,
      height: height ?? 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: enable
            ? MedScribe_Theme.enable_button_theme
            : MedScribe_Theme.disable_button_theme.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Image.asset(iconPath),
          )
        ],
      ),
    );
  }

  static Widget drawerContainer(
      {required BuildContext context,
      required AnimationController animationController,
      required String dragabbleTitle,
      required String aboutUsText,
      required ValueChanged<bool> onDrawerChanged}) {
    double minHeight = 0.0;
    double maxHeight = 0.55;

    return GestureDetector(
      onTap: () => {
        onDrawerChanged(true),
      },
      onVerticalDragUpdate: (details) {
        animationController.value -=
            details.primaryDelta! / MediaQuery.of(context).size.height;
      },
      onVerticalDragEnd: (details) {
        animationController.reverse();
        onDrawerChanged(false);
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 50),
            curve: Curves.easeOut,
            height: (minHeight +
                    (maxHeight - minHeight) * animationController.value) *
                MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: MedScribe_Theme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 7.0,
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.grey,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    Text(
                      dragabbleTitle,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 27,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                      ),
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFD9D9D9),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5.0),
                          Center(
                            child: Image.asset(
                              "assets/about_icon.png",
                              scale: 2.0,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: Text(
                              aboutUsText,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }

  static Widget doctordrawerContainer({
    required BuildContext context,
    required AnimationController animationController,
    required String dragabbleTitle,
    required TextEditingController controller,
    required ValueChanged<bool> onDrawerChanged,
    required Function proceed,
  }) {
    double minHeight = 0.0;
    double maxHeight = 0.55;

    return GestureDetector(
      onTap: () => {
        onDrawerChanged(true),
      },
      onVerticalDragUpdate: (details) {
        animationController.value -=
            details.primaryDelta! / MediaQuery.of(context).size.height;
      },
      onVerticalDragEnd: (details) {
        animationController.reverse();
        onDrawerChanged(false);
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 50),
            curve: Curves.easeOut,
            height: (minHeight +
                    (maxHeight - minHeight) * animationController.value) *
                MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: MedScribe_Theme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 7.0,
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.grey,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    Text(
                      dragabbleTitle,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 27,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                    Text(
                      "The unique code, each patient has.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.08,
                        left: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: MedScribe_Widgets.text_field(
                        controller: controller,
                        hintText: "Patient Code Here",
                        prefixIconPath: "assets/lock.png",
                        keyboardType: TextInputType.streetAddress,
                        prefixIconWidth: 32.0,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: MedScribe_Widgets.underline(),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.1,
                        horizontal: MediaQuery.of(context).size.width * 0.2,
                      ),
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.secondary_color,
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              proceed(controller.text);
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.height * 0.05,
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                "Proceed",
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: MedScribe_Theme.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Image.asset("assets/right_arrow.png"),
                        SizedBox(width: 10.0),
                      ]),
                    )
                  ]),
            ),
          );
        },
      ),
    );
  }

  static Widget transcriptionButton({
    required BuildContext context,
    required String text,
    required Function() onTap,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.1,
        horizontal: MediaQuery.of(context).size.width * 0.2,
      ),
      decoration: BoxDecoration(
        color: MedScribe_Theme.secondary_color,
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              onTap();
            },
            child: Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.height * 0.05,
              ),
              child: Text(
                textAlign: TextAlign.center,
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MedScribe_Theme.white,
                ),
              ),
            ),
          ),
        ),
        Image.asset("assets/right_arrow.png"),
        SizedBox(width: 10.0),
      ]),
    );
  }

  static Widget drawerContainer2(
      {required BuildContext context,
      required AnimationController animationController,
      required String dragabbleTitle,
      required String description,
      required String qrURL,
      required ValueChanged<bool> onDrawerChanged}) {
    double minHeight = 0.0;
    double maxHeight = 0.55;

    return GestureDetector(
      onTap: () => {
        onDrawerChanged(true),
      },
      onVerticalDragUpdate: (details) {
        animationController.value -=
            details.primaryDelta! / MediaQuery.of(context).size.height;
      },
      onVerticalDragEnd: (details) {
        animationController.reverse();
        onDrawerChanged(false);
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 50),
            curve: Curves.easeOut,
            height: (minHeight +
                    (maxHeight - minHeight) * animationController.value) *
                MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: MedScribe_Theme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 7.0,
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.grey,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    Text(
                      dragabbleTitle,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 27,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                    Text(
                      "QR Code",
                      style: GoogleFonts.inter(
                        color: Color(0xFF9F9E9E),
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: QrImageView(
                        data: qrURL,
                        version: QrVersions.auto,
                        semanticsLabel: 'Patient Profile Code',
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: MedScribe_Theme.secondary_color,
                        ),
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: MedScribe_Theme.secondary_color),
                        size: 200.0,
                      ),
                    ),
                    Container(
                        child: Text(qrURL,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D3D3D),
                            ))),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.15,
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        description,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    )
                  ]),
            ),
          );
        },
      ),
    );
  }

  static Widget doctorRegisterationTitleText({required String title}) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: MedScribe_Theme.black,
      ),
    );
  }

  static Widget patientReadingWidgets({
    required BuildContext context,
    required String textHint,
    required String headerText,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Stack(
        children: [
          Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.20,
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.1,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.35,
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFD6D4D4),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextField(
                  showCursor: false,
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: textHint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFADA9A9),
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF676767),
                  ),
                ),
              )),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.19,
            left: MediaQuery.of(context).size.width * 0.67,
            child: Text(
              headerText,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF676767),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget doctorRegisterationTitleTextWithCaption(
      {required String title, required String caption}) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: MedScribe_Theme.black,
        ),
        children: <TextSpan>[
          TextSpan(text: title),
          TextSpan(
            text: caption,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: MedScribe_Theme.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget doctorRegisterationTitleTextWithIcon(
      {required String title, required String imagePath}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: MedScribe_Theme.black,
            ),
          ),
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(imagePath, height: 32, width: 32),
            ),
          ),
        ],
      ),
    );
  }

  static Widget doctorRegisterationDropDown({
    required String hintText,
    required Function onChanged,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      icon: Image.asset(
        "assets/down_button.png",
        color: Color(0xFF8D8A8A),
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFD6D4D4),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFD6D4D4),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MedScribe_Theme.secondary_color,
            width: 1.0,
          ),
        ),
      ),
      hint: Text(
        hintText,
        style: GoogleFonts.inter(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8D8A8A),
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        onChanged(newValue);
      },
    );
  }

  static Widget doctorRegisterationTextField(
      {required String hintText, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(
        color: MedScribe_Theme.secondary_color,
        fontSize: 19,
        fontWeight: FontWeight.w500,
      ),
      textCapitalization: TextCapitalization.words,
      showCursor: false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: Color(0xFF8D8A8A),
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFD6D4D4),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFD6D4D4),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MedScribe_Theme.secondary_color,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  static Widget height_scale({required double height}) {
    return SizedBox(
      height: height,
    );
  }

  static Widget blood_group_tile(
      {required Function onTap,
      required String bloodGroup,
      required bool type,
      required BuildContext context}) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: GestureDetector(
        key: ValueKey(type),
        onTap: () {
          onTap();
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            color:
                type ? MedScribe_Theme.secondary_color : MedScribe_Theme.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: MedScribe_Theme.secondary_color,
              width: 1,
            ),
          ),
          child: Text(
            bloodGroup,
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              color: type ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  static Widget doctorMainScreenTitle(
      {required String iconPath, required String title}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedScribe_Theme.secondary_color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 87,
            height: 89,
          ),
          Text(
            textAlign: TextAlign.center,
            title,
            style: GoogleFonts.inter(
              color: MedScribe_Theme.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }

  static Widget doctorMainScreenButtonV1(
      {required String text,
      required Function() onTap,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
        ),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: MedScribe_Theme.secondary_color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MedScribe_Theme.white,
          ),
        ),
      ),
    );
  }

  static Widget doctor_profile_button(
      {required double width,
      required bool enable,
      required String text,
      required String iconPath,
      required BuildContext context,
      double? height}) {
    return Container(
      width: width,
      height: height ?? 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0),
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF9B63),
            Color(0xFFFF621F),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.1),
            child: Image.asset(iconPath),
          )
        ],
      ),
    );
  }
}
