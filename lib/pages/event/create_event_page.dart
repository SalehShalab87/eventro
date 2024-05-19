// ignore_for_file: use_build_context_synchronously

import 'package:eventro/Services/location_picker.dart';
import 'package:eventro/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eventro/components/my_textfield.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

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
  LatLng? _selectedLocation;
  List<Map<String, dynamic>> eventTypes = [
    {'name': 'Festival', 'icon': Icons.festival},
    {'name': 'Music Event', 'icon': Icons.music_note},
    {'name': 'Sports Event', 'icon': Icons.sports_soccer},
    {'name': 'Coffee House Meetup', 'icon': Icons.local_cafe},
    {'name': 'Charity Event', 'icon': Icons.volunteer_activism},
    {'name': 'Cycles Event', 'icon': Icons.directions_bike},
    {'name': 'Birthday Party', 'icon': Icons.cake},
    {'name': 'Wedding', 'icon': Icons.wc},
    {'name': 'Art Exhibition', 'icon': Icons.brush},
    {'name': 'Theater Play', 'icon': Icons.theater_comedy},
    {'name': 'Movie Night', 'icon': Icons.movie},
  ];

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

  Future<void> _selectEventType(BuildContext context) async {
    String? selectedType = _eventTypeController.text;

    final String? pickedType = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Event Type'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: eventTypes.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile<String>(
                  activeColor: const Color(0xffEC6408),
                  title: Text(eventTypes[index]['name']),
                  secondary: Icon(eventTypes[index]['icon']),
                  value: eventTypes[index]['name'],
                  groupValue: selectedType,
                  onChanged: (String? value) {
                    Navigator.pop(context, value);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (pickedType != null) {
      setState(() {
        _eventTypeController.text = pickedType;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude,
          selectedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          setState(() {
            _selectedLocation = selectedLocation;
            Placemark placemark = placemarks.first;
            String address =
                placemark.locality ?? placemark.street ?? placemark.name ?? '';
            _locationController.text = address;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error getting location'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadEventToFirestore(BuildContext context) async {
    // Validate form fields
    if (!_validateForm()) {
      return;
    }

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
          title: const Text('Confirm Event Upload'),
          content: const Text('Are you sure you want to upload this event?'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
          ],
        ),
      );

      if (confirm != null && confirm) {
        // Perform the upload if confirmed
        await _uploadEvent(context);
      }
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
    } finally {
      // Close the progress indicator
      Navigator.pop(context);
    }
  }

  bool _validateForm() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please select an image for your event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return false;
    }
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _maxcapacityController.text.isEmpty ||
        _eventTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please fill out all required fields",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _uploadEvent(BuildContext context) async {
    // Perform the actual upload to Firebase Firestore
    final ref = FirebaseStorage.instance
        .ref()
        .child('event_images')
        .child(DateTime.now().toString());
    await ref.putFile(_image!);
    final imageUrl = await ref.getDownloadURL();

    // Convert user input date/time to a Timestamp object
    final selectedDateTime = DateTime.parse(_dateTimeController.text);
    final timestamp = Timestamp.fromDate(selectedDateTime);

    // Check if the event already exists
    final existingEvents = await FirebaseFirestore.instance
        .collection('eventsCollection')
        .where('title', isEqualTo: _titleController.text)
        .where('location', isEqualTo: _locationController.text)
        .where('datetime', isEqualTo: timestamp)
        .get();

    if (existingEvents.docs.isNotEmpty) {
      // Display error message if event already exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "An event with the same title, location, and date/time already exists",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return; // Exit function without creating a new event
    }

    // Create a map with the event data
    final eventData = {
      'imageUrl': imageUrl,
      'location': _locationController.text,
      'lat': _selectedLocation!.latitude,
      'long': _selectedLocation!.longitude,
      'title': _titleController.text,
      'price': 'Free', // Assuming price is always free
      'description': _descriptionController.text,
      'datetime': DateTime.parse(_dateTimeController.text),
      'eventType': _eventTypeController.text,
      'maxCapacity': int.parse(_maxcapacityController.text),
      'currentAttendees': 0,
      'status': 'pending', // Set approval status to pending
      'creatorId': FirebaseAuth.instance.currentUser!.uid,
    };

    // Upload the event to Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('eventsCollection')
        .add(eventData);

    // Assign the event to the current user
    await _assignEventToCurrentUser(docRef.id);

    _dateTimeController.clear();
    _descriptionController.clear();
    _eventTypeController.clear();
    _locationController.clear();
    _maxcapacityController.clear();
    _titleController.clear();

    // Display success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Event sent to admin we will notify you with it's status",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _assignEventToCurrentUser(String eventId) async {
    try {
      // Get the ID of the current user
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Create a reference to the user's document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Create a reference to the event document
      DocumentReference eventRef = FirebaseFirestore.instance
          .collection('eventsCollection')
          .doc(eventId);

      // Update the user's document to store the event reference
      await userRef.update({
        'events': FieldValue.arrayUnion([eventRef]),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "error : $e",
            style: const TextStyle(color: Colors.white),
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
      body: GestureDetector(
        onTap: () {
          // Remove focus from text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                  controller: _titleController,
                  hintText: 'Event Title',
                  type: TextInputType.text,
                ),

                // Event Type Input Field
                GestureDetector(
                  onTap: () => _selectEventType(context),
                  child: AbsorbPointer(
                    child: InputFiled(
                      controller: _eventTypeController,
                      hintText: 'Event Type',
                      type: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event type';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                //date time
                DateTimeInput(
                  controller: _dateTimeController,
                  hintText: 'Date And Time',
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
                GestureDetector(
                  onTap: () => _selectLocation(context),
                  child: AbsorbPointer(
                    child: InputFiled(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event title';
                        }
                        return null;
                      },
                      controller: _locationController,
                      hintText: 'Select Location',
                      type: TextInputType.text,
                    ),
                  ),
                ),

                //max capacity
                InputFiled(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                  controller: _maxcapacityController,
                  hintText: 'Max Capacity',
                  inputFormatter: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  type: TextInputType.number,
                ),

                //description
                InputFiled(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                  controller: _descriptionController,
                  hintText: 'Description',
                  type: TextInputType.multiline,
                ),

                const SizedBox(
                  height: 20,
                ),

                // Save Button
                MyButton(
                    onTap: () => _uploadEventToFirestore(context),
                    text: 'Upload Event')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
