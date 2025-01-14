import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Predefined place types
  final List<PlaceType> _placeTypes = [
    PlaceType(name: 'Hospitals', icon: Icons.local_hospital, type: 'hospital'),
    PlaceType(name: 'Police', icon: Icons.local_police, type: 'police'),
    PlaceType(
        name: 'Fire Station',
        icon: Icons.local_fire_department,
        type: 'fire_station'),
    PlaceType(
        name: 'Ambulance', icon: Icons.medical_services, type: 'ambulance'),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker();
      });
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    }
  }

  void _searchLocation() async {
    final query = _searchController.text;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final searchLocation = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(query),
              position: searchLocation,
              infoWindow: InfoWindow(title: query),
            ),
          );

          // If current location exists, draw route
          if (_currentPosition != null) {
            _drawRoute(_currentPosition!, searchLocation);
          }

          // Move camera
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(searchLocation, 14),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Location not found');
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    // This is a mock implementation. In a real app, use Google Directions API
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints
        .decodePolyline('_mock_encoded_polyline_here_in_real_implementation');

    List<LatLng> routeCoordinates =
        result.map((point) => LatLng(point.latitude, point.longitude)).toList();

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void _searchNearbyPlaces(PlaceType placeType) async {
    // Implement actual nearby search using Google Places API
    // This is a mock implementation
    if (_currentPosition == null) return;

    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value != 'current_location');
    });

    // Mock nearby places
    final mockPlaces = [
      NearbyPlace(
        name: '${placeType.name} 1',
        location: LatLng(
          _currentPosition!.latitude + 0.01,
          _currentPosition!.longitude + 0.01,
        ),
        address: '123 Mock Street',
      ),
      NearbyPlace(
        name: '${placeType.name} 2',
        location: LatLng(
          _currentPosition!.latitude - 0.01,
          _currentPosition!.longitude - 0.01,
        ),
        address: '456 Sample Avenue',
      ),
    ];

    for (var place in mockPlaces) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(place.name),
            position: place.location,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.address,
            ),
          ),
        );
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _placeTypes.length,
              itemBuilder: (context, index) {
                final placeType = _placeTypes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () => _searchNearbyPlaces(placeType),
                    icon: Icon(placeType.icon),
                    label: Text(placeType.name),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

class PlaceType {
  final String name;
  final IconData icon;
  final String type;

  PlaceType({
    required this.name,
    required this.icon,
    required this.type,
  });
}

class NearbyPlace {
  final String name;
  final LatLng location;
  final String address;

  NearbyPlace({
    required this.name,
    required this.location,
    required this.address,
  });
}
