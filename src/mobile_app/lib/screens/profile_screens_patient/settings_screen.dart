import 'package:flutter/material.dart';
import 'package:medscribe_app/utils/widgets.dart';

class SettingScreen extends StatefulWidget {
  final Function action;
  final Function action2;
  SettingScreen({required this.action, required this.action2, Key? key})
      : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
              onTap: () {
                widget.action2();
              },
              buttonText: "Patient Code",
              buttonIconPath: "assets/code_lock.png",
            ),
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
          ],
        ));
  }
}
