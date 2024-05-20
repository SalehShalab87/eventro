// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _pickedImage;
  bool isLoading = false;
  String? downloadURL;
  String name = '';
  String email = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode.dispose();
  }

  Future<void> _fetchAdminData() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('admin').doc('eventroadmin').get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          downloadURL = data['photoUrl'] ?? '';
        });
      }
    } catch (e) {
      if (context.mounted) {
        ShowErrorMessage.showError(context, e.toString());
      }
    }
  }

  Future<void> _updateAdminProfile(BuildContext context) async {
    // Show circular progress indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xffEC6408),
          ),
        );
      },
    );
    try {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Profile Update'),
          content: const Text('Are you sure you want to update your profile?'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
          ],
        ),
      );

      if (confirm != null && confirm) {
        // Validate the fields
        if (!_validateFields()) {
          return;
        }

        // Perform the update if confirmed and fields are valid
        await _updateProfile(context);
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error updating profile: $e",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      // Close the progress indicator
      Navigator.pop(context);
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        // Show an error message if the passwords don't match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // Update the admin's profile data in Firestore
      await _firestore.collection('admin').doc('eventroadmin').update({
        'name': _nameController.text,
        'email': _emailController.text,
        // Update other fields as needed
      });

      // Update the admin's password if provided
      if (_passwordController.text.isNotEmpty) {
        await _firestore.collection('admin').doc('eventroadmin').update({
          'password': _passwordController.text,
          // Update other fields as needed
        });
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear the text fields and reset the picked image state
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        showLoadingIndicator();

        // Upload image to Firebase Storage
        final file = File(pickedFile.path);
        const fileName = 'admin_profile_image.png'; // Set your desired path
        final reference =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await reference.putFile(file);

        // Get the download URL
        downloadURL = await reference.getDownloadURL();

        // Update the admin's profile image URL in Firestore
        await _firestore
            .collection('admin')
            .doc('eventroadmin')
            .update({'photoUrl': downloadURL});

        setState(() {
          _pickedImage = file;
        });

        hideLoadingIndicator();
      }
    } catch (e) {
      if (context.mounted) {
        ShowErrorMessage.showError(context, e.toString());
      }
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

  bool _validateFields() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Remove focus from text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 20),
                MyNameTextField(
                    focusNode: _searchFocusNode,
                    controller: _nameController,
                    hintText: 'Name: $name'),
                const SizedBox(height: 10),
                MyEmailTextField(
                    controller: _emailController,
                    hintText: 'Email: $email',
                    obscuretext: false),
                const SizedBox(height: 10),
                MyPasswordTextField(
                    controller: _passwordController, hinttext: 'Password'),
                const SizedBox(height: 10),
                MyConfirmPasswordTextField(
                    controller: _confirmPasswordController,
                    hinttext: 'Confirm Password'),
                const SizedBox(height: 20),
                MyButton(
                    onTap: () => _updateAdminProfile(context),
                    text: 'Save Changes'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
