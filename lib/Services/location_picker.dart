// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _animateToLocation(_selectedLocation!);
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation ?? const LatLng(31.963158, 35.930359),
          zoom: 12,
        ),
        onTap: _onMapTapped,
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation!,
                ),
              }
            : {},
        gestureRecognizers: {
          Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              backgroundColor: const Color(0xffEC6408),
              foregroundColor: Colors.black,
              onPressed: _selectedLocation != null ? _confirmLocation : null,
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}
