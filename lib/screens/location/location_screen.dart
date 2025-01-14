import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};

  // Google Places API Key (replace with your actual key)
  static const String _placesApiKey = 'AIzaSyCVS093QECgowNhmD_aVFn6ilm3WauW7MQ';

  // Predefined place types for quick search
  final List<PlaceType> _placeTypes = [
    PlaceType(name: 'Hospitals', type: 'hospital'),
    PlaceType(name: 'Police Stations', type: 'police'),
    PlaceType(name: 'Fire Stations', type: 'fire_station'),
    PlaceType(name: 'Pharmacies', type: 'pharmacy'),
    PlaceType(name: 'Emergency Services', type: 'emergency_services'),
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

  Future<void> _searchNearbyPlaces(String query) async {
    if (_currentPosition == null) {
      _showErrorSnackBar('Location not available');
      return;
    }

    // Clear existing markers except current location
    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value != 'current_location');
    });

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
          'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          '&radius=5000' // 5 km radius
          '&keyword=$query'
          '&key=$_placesApiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];

          for (var place in results) {
            final location = place['geometry']['location'];
            final marker = Marker(
              markerId: MarkerId(place['place_id']),
              position: LatLng(location['lat'], location['lng']),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: place['vicinity'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            );

            setState(() {
              _markers.add(marker);
            });
          }

          // Move camera to first result if available
          if (results.isNotEmpty) {
            final firstResult = results.first['geometry']['location'];
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(firstResult['lat'], firstResult['lng']),
                13,
              ),
            );
          }
        } else {
          _showErrorSnackBar('No results found');
        }
      } else {
        _showErrorSnackBar('Error searching places');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
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
        title: const Text('Nearby Services'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search nearby services (e.g., hospital, police)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchNearbyPlaces(_searchController.text);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Quick Search Buttons
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _placeTypes.length,
              itemBuilder: (context, index) {
                final placeType = _placeTypes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => _searchNearbyPlaces(placeType.type),
                    child: Text(placeType.name),
                  ),
                );
              },
            ),
          ),

          // Map
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
  final String type;

  PlaceType({
    required this.name,
    required this.type,
  });
}
