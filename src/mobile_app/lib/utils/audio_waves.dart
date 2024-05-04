import 'package:flutter/material.dart';

class AudioWaves extends StatefulWidget {
  @override
  _AudioWavesState createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: -MediaQuery.of(context).size.width * _controller.value,
              child: child!,
            );
          },
          child: Image.asset('assets/recording_waves_active.png'),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: MediaQuery.of(context).size.width * (1 - _controller.value),
              child: child!,
            );
          },
          child: Image.asset('assets/recording_waves_active.png'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
