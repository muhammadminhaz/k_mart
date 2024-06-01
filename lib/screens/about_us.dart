import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class AboutUs extends StatefulWidget {
  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  showErrorDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Failed'),
          content: const Text('Could not contact. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  contact() async {
    final Email send_email = Email(
      subject: 'Contact',
      recipients: ['redminlab@gmail.com'],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(send_email);
    } catch (e) {
      showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black, size: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("About Us"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: contact, child: const Icon(Icons.email),),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Red-Min Lab',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Partner in Software Innovation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'At Red-Min Lab, we are passionate about crafting exceptional software solutions '
              'that empower businesses and individuals. With our team of expert developers and '
              'cutting-edge technologies, we transform ideas into reality.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Our mission is to create software that makes a difference. We strive for excellence '
              'in every project, delivering innovative, reliable, and user-friendly applications '
              'that drive success while also being cost-effective.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Contact Info\n Phone: +8801937370014\n Email: redminlab@gmail.com',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
