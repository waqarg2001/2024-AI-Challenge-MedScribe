import 'package:flutter/material.dart';
import 'package:medscribe_app/utils/widgets.dart';

class DoctorSettings extends StatefulWidget {
  const DoctorSettings({super.key, required this.action});
  final Function action;

  @override
  State<DoctorSettings> createState() => _DoctorSettingsState();
}

class _DoctorSettingsState extends State<DoctorSettings> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.50,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MedScribe_Widgets.setting_screen_button(
              context: context,
              onTap: () {},
              buttonText: "Change Password",
              buttonIconPath: "assets/password_lock.png",
            ),
            MedScribe_Widgets.setting_screen_button(
              context: context,
              onTap: () {},
              buttonText: "Visit Website",
              buttonIconPath: "assets/website_globe.png",
            ),
            MedScribe_Widgets.setting_screen_button(
              context: context,
              onTap: () {
                widget.action();
              },
              buttonText: "About Us",
              buttonIconPath: "assets/about_info.png",
            ),
            MedScribe_Widgets.setting_screen_button(
              context: context,
              onTap: () {},
              buttonText: "Logout",
              buttonIconPath: "assets/logout_icon.png",
            ),
          ],
        ));
  }
}
