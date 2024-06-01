import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:k_mart/constants/app_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showOnboarding = false;
  bool isLatestVersion = true;
  String appLink = "";

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
    _checkLatestVersion();
    _checkAppLink();
  }

  void _checkAppLink() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('version')
        .doc('app_version')
        .get();

    if (snapshot.exists) {
      var latestVersion = snapshot.data()!['number'];
      if (latestVersion != appVersion) {
        isLatestVersion = false;
      }
      print('App version number: $latestVersion');
    } else {
      print('Document does not exist');
    }
  }

  void _checkLatestVersion() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('version')
        .doc('app_version')
        .get();

    if (snapshot.exists) {
      var latestVersion = snapshot.data()!['number'];
      if (latestVersion != appVersion) {
        setState(() {
          isLatestVersion = false;
        });
      }
      print('App version number: $latestVersion');
    } else {
      print('Document does not exist');
    }
  }

  late SharedPreferences prefs;

  void _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    setState(() {
      _showOnboarding = !hasSeenOnboarding;
    });
  }

  _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => ShowCaseWidget(
            builder: Builder(
          builder: (context) => const MyHomePage(
            title: 'Marketplace',
            showcase: true,
          ),
        )), // Replace 'NextScreen' with your desired screen.
      ),
    );
  }

  _openAppLink() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('version')
        .doc('latest_app_link')
        .get();

    if (snapshot.exists) {
      var link = snapshot.data()!['Link'];

      if (await canLaunch(link)) {
        await launch(link);
      } else {
        print('Could not launch $link');
      }
    }
  }

  final List<PageViewModel> onboardingPages = [
    PageViewModel(
      title: "Welcome To\n KAU Marketplace",
      body:
          "Post the items you want to sell\n Filter out the items you need\n Directly contact the seller\n \n P.S. All items expire after 30 days\n For any query, Contact us",
      image: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Image.asset(
              "assets/images/splash.jpg",
              fit: BoxFit.cover,
            )),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 16.0),
        imagePadding: EdgeInsets.all(24.0),
      ),
    ),
    // Add more pages as needed
  ];

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen();
  }

  buildSplashScreen() {
    print(isLatestVersion);
    if (isLatestVersion) {
      return _showOnboarding
          ? introductionScreen()
          : const MyHomePage(title: "Marketplace", showcase: false);
    } else {
      return Scaffold(
          body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Card(
            elevation: 10, // Control the shadow intensity
            shadowColor: Colors.green, // Shadow color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please click here to download the updated app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _openAppLink,
                    child: Text('Download'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
  }

  introductionScreen() {
    return IntroductionScreen(
      pages: onboardingPages,
      showNextButton: false,
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () async {
        print("yes");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);
        String uniqueToken = await generateUniqueToken();
        await storeToken(uniqueToken);
        _navigateToNextScreen();
      },
    );
  }
}

Future<String> generateUniqueToken() async {
  final String uuid = "User_token_${Uuid().v4()}";
  return uuid;
}

Future<void> storeToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_token', token);
}
