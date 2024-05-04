// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:path_provider/path_provider.dart';

// class FaceDetection extends StatefulWidget {
//   const FaceDetection({super.key});

//   @override
//   State<FaceDetection> createState() => _FaceDetectionState();
// }

// class _FaceDetectionState extends State<FaceDetection> {
//   final ImagePicker _picker = ImagePicker();

//   Future<void> detectFace() async {
//     // Capture an image
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//     if (image == null) return;

//     final inputImage = InputImage.fromFilePath(image.path);
//     final faceDetector = GoogleMlKit.vision.faceDetector(
//       FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.accurate,
//         enableClassification: true,
//       ),
//     );
//     List<Face> faces = await faceDetector.processImage(inputImage);

//     if (faces.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("No Face Detected"),
//             content: Text("Please try again."),
//           );
//         },
//       );
//     } else {
//       // Proceed with the first detected face
//       Face firstFace = faces.first;
//       // Crop the image to the bounding box of the first face
//       img.Image originalImage =
//           img.decodeImage(File(image.path).readAsBytesSync())!;
//       img.Image croppedImage = img.copyCrop(
//         originalImage,
//         x: firstFace.boundingBox.left.toInt(),
//         y: firstFace.boundingBox.top.toInt(),
//         width: firstFace.boundingBox.width.toInt(),
//         height: firstFace.boundingBox.height.toInt(),
//       );

//       final directory = await getApplicationDocumentsDirectory();
//       final path = directory.path;
//       String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       File croppedFile = File('$path/$timestamp.png')
//         ..writeAsBytesSync(img.encodePng(croppedImage));

//       FirebaseStorage storage = FirebaseStorage.instance;
//       try {
//         await storage
//             .ref('uploads/${croppedFile.path.split('/').last}')
//             .putFile(croppedFile);
//       } on FirebaseException catch (e) {
//         // Handle any errors
//         print(e);
//       }

//       faceDetector.close();

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Face Detected"),
//             content: Text("Face has been successfully detected."),
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Face Detection Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             detectFace();
//           },
//           child: Text('Detect Face'),
//         ),
//       ),
//     );
//   }
// }
