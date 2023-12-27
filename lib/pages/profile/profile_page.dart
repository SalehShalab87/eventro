// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/Services/auth/sign_out.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/profile_list_tile.dart';
import 'package:eventro/pages/about_page.dart';
import 'package:eventro/pages/event/favorite_page.dart';
import 'package:eventro/pages/event/user_events.dart';
import 'package:eventro/pages/profile/upadte_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  String userEmail = '';
  File? _pickedImage;
  bool isLoading = false;
  String? downloadURL;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    initPrefs();
  }

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Retrieve the file path of the picked image
    final imagePath = _prefs.getString('picked_image_path');
    if (imagePath != null) {
      setState(() {
        _pickedImage = File(imagePath);
      });
    }
  }

  Future<void> saveImagePath(String path) async {
    // Save the file path of the picked image
    await _prefs.setString('picked_image_path', path);
  }

  Future<void> fetchUserEmail() async {
    try {
      DocumentSnapshot userDoc = await users.doc(currentUser.uid).get();
      String email = userDoc['email'] ?? '';
      setState(() {
        userEmail = email;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while fetching the user email: $e'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xffEC6408),
                    width: 3.0,
                  ),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircleAvatar(
                        backgroundImage: _pickedImage != null
                            ? Image.file(_pickedImage!).image
                            : NetworkImage(
                                downloadURL ?? currentUser.photoURL ?? ''),
                        radius: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xffEC6408),
                        ),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const Icon(
                            LineAwesomeIcons.alternate_pencil,
                            color: Colors.black,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: Center(
                          child: buildLoadingIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                currentUser.displayName!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyButton(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen(),
                  ),
                ),
                text: 'Edit Profile',
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const SizedBox(height: 10),
              //menu section
              ProfileMenuWidget(
                tilte: 'My Events',
                iconData: Icons.calendar_month_outlined,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyEvents(),
                    )),
              ),
              ProfileMenuWidget(
                tilte: 'My Favorites',
                iconData: Icons.favorite_outlined,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritePage(),
                    )),
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              ProfileMenuWidget(
                tilte: 'About',
                iconData: LineAwesomeIcons.info,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    )),
              ),
              ProfileMenuWidget(
                tilte: 'Log Out',
                iconData: Icons.logout_outlined,
                onPress: () => signOutFromFirebase(context),
                endIcon: false,
                textcolor: Colors.red[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        showLoadingIndicator();

        // Upload image to Firebase Storage
        final file = File(pickedFile.path);
        final fileName =
            'profile_images/${currentUser.uid}.png'; // Set your desired path
        final reference =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await reference.putFile(file);

        // Get the download URL
        downloadURL = await reference.getDownloadURL();

        setState(() {
          _pickedImage = file;
        });

        // Save the file path
        saveImagePath(pickedFile.path);

        hideLoadingIndicator();
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred while picking the image: $e'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

  void showLoadingIndicator() {
    setState(() {
      isLoading = true;
    });
  }

  void hideLoadingIndicator() {
    setState(() {
      isLoading = false;
    });
  }

  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xffEC6408),
      ),
    );
  }
}
