// ignore_for_file: use_build_context_synchronously

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_tawselti/main_screen.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class SplashScreenTawselti extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String username;

  const SplashScreenTawselti({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.username,
  });

  @override
  State<SplashScreenTawselti> createState() => _SplashScreenTawseltiState();
}

class _SplashScreenTawseltiState extends State<SplashScreenTawselti> {
  bool _isVisible = false;
  bool _exitScreen = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _playCarSound();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVisible = true;
      });

      Future.delayed(const Duration(seconds: 4), () {
        setState(() {
          _exitScreen = true;
        });
      });
    });

    Future.delayed(
      const Duration(seconds: 7),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreenTawselti(
              latitude: widget.latitude,
              longitude: widget.longitude,
              username: widget.username,
            ),
          ),
        );
      },
    );
  }

  Future<void> _playCarSound() async {
    await _audioPlayer.play(AssetSource('sounds/car_sound.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundSplashScreen(
        child: Center(
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                left: _isVisible
                    ? _exitScreen
                        ? MediaQuery.of(context).size.width + 100
                        : MediaQuery.of(context).size.width / 2 - 175
                    : -300,
                top: MediaQuery.of(context).size.height / 2 - 175,
                child: Image.asset(
                  'assets/image/tawselti-logo.png',
                  width: 350,
                  height: 350,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
