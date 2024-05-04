import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  String? acc_type = Get.parameters['acc_type'];
  String? userId = Get.parameters['userId'];
  Duration _animationDuration = Duration(milliseconds: 500);
  bool _isImageSelected = false, _enablebutton = false;
  String? downloadUrl;

  Future<void> selectImage(String sourceType) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
        source:
            sourceType == 'gallery' ? ImageSource.gallery : ImageSource.camera);

    if (image != null) {
      // Use the image file
      print('Selected image path: ${image.path}');
      setState(() {
        _isImageSelected = true;
        _enablebutton = true;
      });
      try {
        Reference storageReference = FirebaseStorage.instance.ref().child(
            acc_type == "Doctor"
                ? "Doctors/$userId/${image.name}"
                : "Patients/$userId/${image.name}");

        UploadTask uploadTask = storageReference.putFile(File(image.path));

        await uploadTask.whenComplete(() async {
          print('Image uploaded');
          String url = await storageReference.getDownloadURL();
          print('Download URL: $url');
          setState(() {
            downloadUrl = url;
          });
        });
      } catch (e) {
        print('Error uploading image: $e');
      }

      setState(() {
        _isImageSelected = true;
        _enablebutton = true;
      });
    } else {
      print('No image selected.');
      setState(() {
        _isImageSelected = false;
        _enablebutton = false;
        downloadUrl = null;
      });
    }
  }

  void updateUserImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection(acc_type == 'Doctor' ? 'Doctors' : 'Patients')
          .doc(userId)
          .update({'image': imageUrl}).then((value) => Get.snackbar(
                "Success",
                "Image uploaded successfully!",
                snackPosition: SnackPosition.TOP,
                backgroundColor: MedScribe_Theme.secondary_color,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
                margin: EdgeInsets.all(8),
                borderRadius: 8,
                isDismissible: true,
                forwardAnimationCurve: Curves.fastOutSlowIn,
                reverseAnimationCurve: Curves.fastOutSlowIn,
                icon: Icon(Icons.check_circle, color: Colors.white, size: 20),
                shouldIconPulse: true,
              ));
    } catch (e) {
      print('Error updating user image: $e');
      Get.snackbar(
        "Error",
        "Error uploading image. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        isDismissible: true,
        forwardAnimationCurve: Curves.fastOutSlowIn,
        reverseAnimationCurve: Curves.fastOutSlowIn,
        icon: Icon(Icons.error, color: Colors.white, size: 20),
        shouldIconPulse: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Container(
                            child: Image.asset(
                              scale: 1,
                              acc_type == "Doctor"
                                  ? "assets/doctor_logo.png"
                                  : "assets/patient_logo.png",
                            ),
                          ),
                          Container(
                            child: Text(
                              "Almost there!",
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "Upload your photo",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF252525),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  //select image from gallery
                  selectImage('gallery');
                },
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: MediaQuery.of(context).size.height * 0.20,
                    decoration: BoxDecoration(
                      color: Color(0xFFE4E3E3),
                      border: Border.all(
                        color: Color(0xFFFF8347),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.asset(
                            "assets/photo_temp.png",
                            scale: 1,
                          ),
                        ),
                        Container(
                          child: Text(
                            "Upload your Photo",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF252525),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              MedScribe_Widgets.or_text_widget(context: context),
              GestureDetector(
                onTap: () {
                  selectImage('camera');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02),
                  child: MedScribe_Widgets.google_button(
                    backColor: MedScribe_Theme.secondary_color,
                    iconPath: "assets/camera_icon.png",
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: MediaQuery.of(context).size.height * 0.05,
                    text1: "Take Photo",
                    radius: 50,
                    shadow: false,
                    iconHeight: 35,
                    iconWidth: 35,
                    textColor: Colors.white,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: _animationDuration,
                child: GestureDetector(
                  key: Key(_isImageSelected.toString()),
                  onTap: () {
                    if (_enablebutton &&
                        _isImageSelected &&
                        downloadUrl != null &&
                        downloadUrl!.isNotEmpty) {
                      // Move to the Main Dashboard Screen
                      updateUserImage(downloadUrl!);
                    }
                  },
                  child: MedScribe_Widgets.button_widget(
                    width: MediaQuery.of(context).size.width * 0.75,
                    enable: _enablebutton,
                    text: "Next",
                    iconPath: "assets/forward_icon.png",
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
