import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:campus_cooks/views/camera_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}



class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/images/meal.gif",
            width: 300,
            height: 200,
          ),
          const SizedBox(height: 20),
          Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
                fontFamily: 'Bobbers',
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Campus Cooks'),
                ],
              ),
            ),
          ),
          const Padding(
              padding: EdgeInsets.all(50),
              child: Text(
                "Get recipes from your pic in seconds",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black),
                textAlign: TextAlign.center,
              )),
          ElevatedButton(
            onPressed: () async {
                await availableCameras().then((value) => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
// await takePicture();
              // Navigator.of(context).push(
              //         MaterialPageRoute(builder: (context) {
              //           return ResultsPage();
              //         }),
              //       );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20),
                  ),
            ),
          ),
        ]),
      ),
    );
  }
}
