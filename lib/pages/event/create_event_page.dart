// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eventro/components/my_textfield.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  File? _image;
  final picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _eventTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxcapacityController;
  late TextEditingController _dateTimeController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _eventTypeController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxcapacityController = TextEditingController();
    _locationController = TextEditingController();
    _dateTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxcapacityController.dispose();
    _eventTypeController.dispose();
    _dateTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadEventToFirestore() async {
    if (_image != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child(DateTime.now().toString());
        await ref.putFile(_image!);
        final imageUrl = await ref.getDownloadURL();

        // Create a map with the event data
        final eventData = {
          'imageUrl': imageUrl,
          'location': _locationController.text,
          'title': _titleController.text,
          'price': 'Free', // Assuming price is always free
          'description': _descriptionController.text,
          'datetime': DateTime.parse(_dateTimeController.text),
          'eventType': _eventTypeController.text,
          'maxCapacity': int.parse(_maxcapacityController.text),
          'currentAttendees': 0,
          'status': 'pending', // Set approval status to pending
        };

        // Upload the event to Firestore
        final docRef = await FirebaseFirestore.instance
            .collection('eventsCollection')
            .add(eventData);

        // Now you can do something with the event, like display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Event sent to admin we will notify you with it's status",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Error uploading event: $e",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } else {
      // Handle case when image is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please select an image for your event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  //dateTime method
  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            // Customize the date picker's color
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xffEC6408), // Change primary color
              onPrimary: Colors.white, // Change text color
            ),
            textTheme: theme.textTheme.copyWith(
              // Optionally change text styles
              labelMedium:
                  const TextStyle(color: Colors.black), // Change text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: theme.copyWith(
              // Customize the time picker's color
              colorScheme: theme.colorScheme.copyWith(
                primary: const Color(0xffEC6408), // Change primary color
                onPrimary: Colors.white, // Change text color
              ),
              textTheme: theme.textTheme.copyWith(
                // Optionally change text styles
                labelMedium:
                    const TextStyle(color: Colors.black), // Change text color
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create My Event',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: getImage,
                child: Container(
                  alignment: Alignment.center,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: _image != null
                      ? Image.file(
                          _image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 20),

              //title
              InputFiled(
                controller: _titleController,
                hintText: 'Event Title',
              ),

              //event type
              InputFiled(
                controller: _eventTypeController,
                hintText: 'Event Type',
              ),

              //date time
              DateTimeInput(
                controller: _dateTimeController,
                hintText: 'Date',
                icon: Icons.calendar_today,
                onPressed: () async {
                  final selectedDateTime = await _selectDateTime(context);
                  if (selectedDateTime != null) {
                    setState(() {
                      _dateTimeController.text = selectedDateTime.toString();
                    });
                  }
                },
              ),

              //location
              InputFiled(
                controller: _locationController,
                hintText: 'Location',
              ),

              //max capacity
              InputFiled(
                controller: _maxcapacityController,
                hintText: 'Max Capacity',
                inputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              //description
              InputFiled(
                controller: _descriptionController,
                hintText: 'Description',
              ),

              const SizedBox(
                height: 20,
              ),

              // Save Button
              MyButton(onTap: _uploadEventToFirestore, text: 'Save')
            ],
          ),
        ),
      ),
    );
  }
}
