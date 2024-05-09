import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 70,
              backgroundImage: const AssetImage('images/slogo.png'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Eventro',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Eventro is an app that helps you discover and manage events in your area. Whether you\'re looking for concerts, festivals, conferences, or sports events, Eventro has you covered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/developer.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saleh Shalab',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Software Developer',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      style: const ButtonStyle(
                          side: WidgetStatePropertyAll<BorderSide>(
                            BorderSide(
                                color: Color(
                                    0xffEC6408)), // Change the color to your desired color
                          ),
                          foregroundColor: WidgetStatePropertyAll(Colors.black),
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xffEC6408))),
                      onPressed: () {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'salehshalab2@gmail.com',
                        );
                        launchUrl(emailLaunchUri);
                      },
                      child: const Text('Contact Me ->'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch email
}
