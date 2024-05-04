// import 'dart:async';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:medscribe_app/utils/network.dart';
// import 'package:medscribe_app/utils/themes.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioRecorder extends StatefulWidget {
//   final Function(String, bool, String) action;
//   AudioRecorder({Key? key, required this.action});

//   @override
//   _AudioRecorderState createState() => _AudioRecorderState();
// }

// class _AudioRecorderState extends State<AudioRecorder>
//     with SingleTickerProviderStateMixin {
//   FlutterSoundRecorder? _recorder;
//   String? _path;
//   bool _isRecording = false;
//   bool _isPaused = false;
//   FlutterSoundPlayer? _player = FlutterSoundPlayer();
//   Duration _duration = Duration();
//   Timer? _timer;
//   Duration _pauseDuration = Duration();
//   bool? _isTranscribing = false;

//   @override
//   void initState() {
//     super.initState();
//     _recorder = FlutterSoundRecorder();
//     _init();
//   }

//   Future<void> _init() async {
//     var status = await Permission.microphone.status;
//     if (!status.isGranted) {
//       await Permission.microphone.request();
//     }
//     await _player!.openPlayer();
//     await _recorder!.openRecorder();
//     var tempDir = await getTemporaryDirectory();
//     _path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
//   }

//   Future<void> _startRecording() async {
//     setState(() {
//       _isRecording = true;
//       _isPaused = false;
//     });
//     var tempDir = await getTemporaryDirectory();
//     _path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
//     try {
//       _duration = Duration();
//       _startTimer();
//       print('File path: $_path');
//       await _recorder!.closeRecorder(); // Close the recorder
//       await _recorder!.openRecorder(); // Open the recorder
//       await _recorder!.startRecorder(
//         toFile: _path,
//         codec: Codec.pcm16WAV,
//       );
//     } catch (e) {
//       print('Error starting recorder: $e'); // Print the error to the console
//     }
//   }

//   Future<void> _pauseRecording() async {
//     if (_isTranscribing!) {
//       return;
//     }
//     _stopTimer();
//     await _recorder!.pauseRecorder();
//     setState(() {
//       _isPaused = true;
//     });
//   }

//   Future<void> _resumeRecording() async {
//     if (_isTranscribing!) {
//       return;
//     }
//     _startTimer();
//     await _recorder!.resumeRecorder();
//     setState(() {
//       _isPaused = false;
//     });
//   }

//   Future<void> _stopRecording() async {
//     _stopTimer();
//     _duration = Duration();
//     await _recorder!.stopRecorder();
//     setState(() {
//       _isRecording = false;
//       _isPaused = false;
//     });
//   }

//   Future<void> _deleteRecording() async {
//     _stopTimer();
//     _duration = Duration();
//     try {
//       if (_path != null) {
//         File file = File(_path!);
//         await file.delete();
//       }
//     } catch (e) {
//       print('Error $e');
//     }
//     var tempDir = await getTemporaryDirectory();
//     await _recorder!.closeRecorder(); // Close the recorder
//     await _recorder!.openRecorder(); // Open the recorder
//     setState(() {
//       _path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
//       _isRecording = false;
//       _isPaused = false;
//     });
//   }

//   Future<void> _sendAudioForTranscription() async {
//     if (_isTranscribing!) {
//       return;
//     }
//     try {
//       widget.action("", true, _path!);
//       _stopTimer();
//       _duration = Duration();
//       setState(() {
//         _isRecording = false;
//         _isTranscribing = true;
//       });

//       var file = File(_path!);

//       // Check if the file exists
//       bool exists = await file.exists();
//       if (!exists) {
//         print('File does not exist: $_path');
//         return;
//       }

//       var dio = Dio();

//       var formData = FormData.fromMap({
//         "audio_file": await MultipartFile.fromFile(_path!),
//       });
//       var response = await dio.post(
//         "${MedScribeBackenAPI().baseURL}/whisperx",
//         data: formData,
//       );

//       print('Upload response: $response');
//       widget.action(response.toString(), false, _path!);
//       setState(() {
//         _isTranscribing = false;
//       });
//     } catch (e) {
//       print('Error uploading file: $e');
//     }
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _duration += Duration(seconds: 1);
//         });
//       }
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           child: Text(
//             _formatDuration(_duration),
//             style: GoogleFonts.inter(
//               color: Color(0xff3D3D3D),
//               fontSize: 48,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//         ),
//         Image.asset(
//           'assets/recording_waves.png',
//           fit: BoxFit.fitWidth,
//           height: 150,
//           width: MediaQuery.of(context).size.width,
//         ),
//         Container(
//           margin: EdgeInsets.only(
//               bottom: MediaQuery.of(context).size.height * 0.05),
//           alignment: Alignment.center,
//           child: _isRecording
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     AnimatedSwitcher(
//                       duration: Duration(milliseconds: 200),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return ScaleTransition(child: child, scale: animation);
//                       },
//                       child: IconButton(
//                         key: ValueKey<bool>(_isRecording),
//                         icon: Image.asset("assets/stop_recording.png"),
//                         onPressed: _deleteRecording,
//                       ),
//                     ),
//                     AnimatedSwitcher(
//                       duration: Duration(milliseconds: 200),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return ScaleTransition(child: child, scale: animation);
//                       },
//                       child: GestureDetector(
//                         key: ValueKey<bool>(_isPaused),
//                         onTap: _isPaused ? _resumeRecording : _pauseRecording,
//                         child: _isPaused
//                             ? Container(
//                                 width: MediaQuery.of(context).size.width * 0.18,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.085,
//                                 decoration: BoxDecoration(
//                                   color: MedScribe_Theme.secondary_color,
//                                   borderRadius: BorderRadius.circular(100),
//                                 ),
//                                 child: FittedBox(
//                                   child: Image.asset(
//                                     "assets/start_recording.png",
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.1,
//                                     height: MediaQuery.of(context).size.height *
//                                         0.06,
//                                     fit: BoxFit.fill,
//                                   ),
//                                 ),
//                               )
//                             : Container(
//                                 width: MediaQuery.of(context).size.width * 0.18,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.085,
//                                 decoration: BoxDecoration(
//                                   color: MedScribe_Theme.secondary_color,
//                                   borderRadius: BorderRadius.circular(100),
//                                 ),
//                                 child: FittedBox(
//                                   child: Image.asset(
//                                     "assets/pause_recording.png",
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.1,
//                                     height: MediaQuery.of(context).size.height *
//                                         0.06,
//                                     fit: BoxFit.fill,
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                     AnimatedSwitcher(
//                       duration: Duration(milliseconds: 200),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return ScaleTransition(child: child, scale: animation);
//                       },
//                       child: IconButton(
//                         key: ValueKey<bool>(_isRecording),
//                         icon: Image.asset('assets/send_recording.png'),
//                         onPressed: _sendAudioForTranscription,
//                       ),
//                     ),
//                   ],
//                 )
//               : AnimatedSwitcher(
//                   duration: Duration(milliseconds: 200),
//                   transitionBuilder:
//                       (Widget child, Animation<double> animation) {
//                     return ScaleTransition(child: child, scale: animation);
//                   },
//                   child: GestureDetector(
//                     key: ValueKey<bool>(_isRecording),
//                     onTap: _startRecording,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.18,
//                       height: MediaQuery.of(context).size.height * 0.085,
//                       decoration: BoxDecoration(
//                         color: MedScribe_Theme.secondary_color,
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                       child: FittedBox(
//                         child: Image.asset(
//                           "assets/start_recording.png",
//                           width: MediaQuery.of(context).size.width * 0.1,
//                           height: MediaQuery.of(context).size.height * 0.06,
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _recorder!.closeRecorder();
//     _recorder = null;
//     _timer?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String, bool, String) action;
  AudioRecorder({Key? key, required this.action});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with SingleTickerProviderStateMixin {
  late Record _recorder;
  String? _path;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _duration = Duration();
  Timer? _timer;
  Duration _pauseDuration = Duration();
  bool? _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _recorder = Record();
    _init();
  }

  Future<void> _init() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
    try {
      _duration = Duration();
      _startTimer();
      print('File path: $_path');
      await _recorder.start();
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  Future<void> _pauseRecording() async {
    if (_isTranscribing!) {
      return;
    }
    _stopTimer();
    await _recorder.pause();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    if (_isTranscribing!) {
      return;
    }
    _startTimer();
    await _recorder.resume();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    _stopTimer();
    _duration = Duration();
    String? path = await _recorder.stop();
    File file = File(path!);
    if (file.existsSync()) {
      file.deleteSync();
    }
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
  }

  Future<void> _deleteRecording() async {
    _stopTimer();
    _duration = Duration();
    try {
      String? path = await _recorder.stop();
      File file = File(path!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('Error $e');
    }
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
  }

  Future<void> _sendAudioForTranscription() async {
    if (_isTranscribing!) {
      return;
    }
    try {
      String? path = await _recorder.stop();
      widget.action("", true, path!);
      _stopTimer();
      _duration = Duration();
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });

      final file = File(path);
      if (!file.existsSync()) {
        print('File does not exist: $path');
        return;
      }

      final url = Uri.parse('${MedScribeBackenAPI().baseURL}/whisperx');

      final request = http.MultipartRequest('POST', url)
        ..files.add(
          http.MultipartFile(
            'audio_file',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: '${DateTime.now().millisecondsSinceEpoch}.mp3',
          ),
        );

      final response = await http.Response.fromStream(await request.send());

      print('Upload response: $response');
      var responseJson = response.body;
      widget.action(responseJson.toString(), false, path);
      setState(() {
        _isTranscribing = false;
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration += Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text(
            _formatDuration(_duration),
            style: GoogleFonts.inter(
              color: Color(0xff3D3D3D),
              fontSize: 48,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Image.asset(
          'assets/recording_waves.png',
          fit: BoxFit.fitWidth,
          height: 150,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.05),
          alignment: Alignment.center,
          child: _isRecording
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: IconButton(
                        key: ValueKey<bool>(_isRecording),
                        icon: Image.asset("assets/stop_recording.png"),
                        onPressed: _deleteRecording,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: GestureDetector(
                        key: ValueKey<bool>(_isPaused),
                        onTap: _isPaused ? _resumeRecording : _pauseRecording,
                        child: _isPaused
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                height:
                                    MediaQuery.of(context).size.height * 0.085,
                                decoration: BoxDecoration(
                                  color: MedScribe_Theme.secondary_color,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: FittedBox(
                                  child: Image.asset(
                                    "assets/start_recording.png",
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                height:
                                    MediaQuery.of(context).size.height * 0.085,
                                decoration: BoxDecoration(
                                  color: MedScribe_Theme.secondary_color,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: FittedBox(
                                  child: Image.asset(
                                    "assets/pause_recording.png",
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: IconButton(
                        key: ValueKey<bool>(_isRecording),
                        icon: Image.asset('assets/send_recording.png'),
                        onPressed: _sendAudioForTranscription,
                      ),
                    ),
                  ],
                )
              : AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  child: GestureDetector(
                    key: ValueKey<bool>(_isRecording),
                    onTap: _startRecording,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.085,
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.secondary_color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FittedBox(
                        child: Image.asset(
                          "assets/start_recording.png",
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.height * 0.06,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
