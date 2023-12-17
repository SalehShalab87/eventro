import 'package:eventro/models/booking.dart';
import 'package:eventro/pages/NotificationPage.dart';
import 'package:eventro/pages/Onboarding_pages.dart';
import 'package:eventro/pages/authpages/auth_page.dart';
import 'package:eventro/pages/authpages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_options2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

int? initScreen;

class Eventro extends StatelessWidget {
  const Eventro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // them data for the application
      theme: ThemeData(
          fontFamily: 'Gilroy',
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: AppBarTheme(backgroundColor: Colors.grey[300])),
      debugShowCheckedModeBanner: false,
      // Set the initial route based on whether the user has seen the onboarding screen
      initialRoute: initScreen == 0 || initScreen == null ? 'onboard' : '/home',
      routes: {
        '/home': (context) => const AuthPage(),
        'onboard': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve the initialization screen preference from shared preferences
  SharedPreferences preferences = await SharedPreferences.getInstance();
  initScreen = preferences.getInt('initScreen');

  // Configure the device orientation to be portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase Storage
  await firebase_storage.FirebaseStorage.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            Booking booking = Booking();
            booking.init(context);
            return booking;
          },
        ),
        // Add other providers as needed
      ],
      child: Builder(
        builder: (context) {
          // Show the onboarding screen for the first time
          if (initScreen == null || initScreen == 0) {
            preferences.setInt('initScreen', 1);
            return const Eventro();
          } else {
            return const Eventro();
          }
        },
      ),
    ),
  );
}
