import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/widgets.dart';

class AccountType extends StatefulWidget {
  const AccountType({super.key});

  @override
  State<AccountType> createState() => _AccountTypeState();
}

class _AccountTypeState extends State<AccountType> {
  bool is_doctor = false, is_patient = false;

  final routeType = Get.parameters['routeType'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          textAlign: TextAlign.center,
          'Choose Account Type',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MedScribe_Widgets.account_type_button(
                    context: context,
                    text: "Doctor",
                    imagePath: "assets/doctor_logo.png",
                    onTap: () {
                      setState(() {
                        is_doctor = true;
                        is_patient = false;
                      });
                    },
                    active: is_doctor,
                  ),
                  MedScribe_Widgets.account_type_button(
                    context: context,
                    text: "Patient",
                    imagePath: "assets/patient_logo.png",
                    onTap: () {
                      setState(() {
                        is_doctor = false;
                        is_patient = true;
                      });
                    },
                    active: is_patient,
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF9B63),
                    Color(0xFFFF621F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  is_doctor || is_patient
                      ? is_patient
                          ? MedScribe_Widgets.route_param_button(
                              text: 'Continue',
                              routePath: routeType == 'login'
                                  ? '/login'
                                  : '/patient_registeration',
                              textColor: Colors.black,
                              paramKey: 'acc_type',
                              paramValue: 'Patient',
                              backgroundColor: Colors.white,
                              context: context,
                            )
                          : MedScribe_Widgets.route_param_button(
                              text: 'Continue',
                              routePath: routeType == 'login'
                                  ? '/login'
                                  : '/doc_registeration',
                              textColor: Colors.black,
                              paramKey: 'acc_type',
                              paramValue: 'Doctor',
                              backgroundColor: Colors.white,
                              context: context,
                            )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                  MedScribe_Widgets.onboarding_button(
                    text: 'Go Back',
                    routePath: '/home',
                    routeParam: '',
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    context: context,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
