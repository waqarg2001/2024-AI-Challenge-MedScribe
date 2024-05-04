import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medscribe_app/utils/themes.dart';

class MedScribeCameraScreen extends StatefulWidget {
  const MedScribeCameraScreen({super.key});

  @override
  State<MedScribeCameraScreen> createState() => _MedScribeCameraScreenState();
}

class _MedScribeCameraScreenState extends State<MedScribeCameraScreen> {
  List<CameraDescription>? cameras;
  CameraController? _controller;
  Future<void>? setupCamerasFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupCamerasFuture = setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      final frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        ),
      );
      _controller = CameraController(frontCamera, ResolutionPreset.ultraHigh);
      await _controller!.initialize();
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('Camera access denied');
            break;
          default:
            print('Error: $e.code\nError Message: $e.description');
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: setupCamerasFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: CameraPreview(_controller!),
                ),
                _getCustomPaintOverlay(context),
              ],
            ),
          );
        } else {
          return const Center(
              child: CircularProgressIndicator(
            color: MedScribe_Theme.secondary_color,
          ));
        }
      },
    );
  }

  CustomPaint _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(
        size: MediaQuery.of(context).size, painter: HolePainter());
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final boundaryPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height * 0.3);

    final radiusX = size.width / 4;
    final radiusY = size.height / 4;

    Path facePath = Path()
      ..addOval(Rect.fromCenter(
          center: center, width: 2.5 * radiusX, height: 1.5 * radiusY))
      ..close();

    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          facePath,
        ),
        paint);

    // Draw the white boundary
    canvas.drawPath(facePath, boundaryPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// class HolePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.black.withOpacity(0.5);

//     final center = Offset(size.width / 2, size.height * 0.3);

//     final radiusX = size.width / 4;
//     final radiusY = size.height / 4;

//     canvas.drawPath(
//         Path.combine(
//           PathOperation.difference,
//           Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
//           Path()
//             ..addOval(Rect.fromCenter(
//                 center: center, width: 2.5 * radiusX, height: 1.5 * radiusY))
//             ..close(),
//         ),
//         paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
