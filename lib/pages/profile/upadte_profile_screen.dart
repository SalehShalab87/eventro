// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  String userEmail = '';
  String userName = '';
  File? _pickedImage;
  bool isLoading = false;
  String? downloadURL;
  late SharedPreferences _prefs;
// Text field Editing Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode f = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    initPrefs();
  }

  // Dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    f.dispose();
    super.dispose();
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
      String name = userDoc['name'] ?? '';
      setState(() {
        userEmail = email;
        userName = name;
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
      body: GestureDetector(
        onTap: () {
          // Remove focus from text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
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
                          backgroundColor: Colors.black,
                          backgroundImage: _pickedImage != null
                              ? Image.file(_pickedImage!).image
                              : NetworkImage(downloadURL ??
                                  currentUser.photoURL ??
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/2048px-Default_pfp.svg.png'),
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
                  userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                const Divider(),
                const SizedBox(height: 10),
                MyNameTextField(
                    focusNode: f,
                    controller: _nameController,
                    hintText: currentUser.displayName!),
                MyEmailTextField(
                    controller: _emailController,
                    hintText: userEmail,
                    obscuretext: false),

                const SizedBox(
                  height: 20,
                ),

                // Sign up button
                MyButton(
                  text: 'Save',
                  onTap: () => SaveUserDetails(),
                ),
              ],
            ),
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

  // ignore: non_constant_identifier_names
  void SaveUserDetails() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Color(0xffEC6408),
            content: Text(
              "Please fill in all details before saving",
              style: TextStyle(color: Colors.black),
            )),
      );
    } else {
      try {
        // Update user details in Firestore
        //cloud
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'email': _emailController.text,
          'name': _nameController.text,
        });

        //auth
        await currentUser.verifyBeforeUpdateEmail(_emailController.text);
        //Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green, // Success color
            content: Text(
              "Details updated successfully. If you changed your email, please verify it again.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red, // Error color
            content: Text(
              "Failed to update details: $e",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    }
  }
}
