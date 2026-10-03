import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../data/favorite_locations.dart';
import '../models/favorite_location.dart';
import '../providers/location_provider.dart';
import '../widgets/favorite_location_list.dart';
import '../widgets/location_info_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;

  // Initial camera position set to Khulna University
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(22.8026, 89.3709),
    zoom: 14.0,
  );

  /// Generates Google Maps Marker objects dynamically from favoriteLocations list
  Set<Marker> _createFavoriteMarkers() {
    return favoriteLocations.map((location) {
      return Marker(
        markerId: MarkerId('favorite_${location.id}'),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: location.name,
          snippet: 'Tap for details',
        ),
        onTap: () {
          _showLocationInfoDialog(location);
        },
      );
    }).toSet();
  }

  /// Displays dialog with location details on marker tap
  void _showLocationInfoDialog(FavoriteLocation location) {
    showDialog(
      context: context,
      builder: (context) => LocationInfoDialog(location: location),
    );
  }

  /// Opens bottom sheet containing list of favorite locations
  void _showFavoriteLocationsList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return FavoriteLocationList(
          onLocationSelected: (location) {
            Navigator.of(bottomSheetContext).pop();
            _moveToLocation(LatLng(location.latitude, location.longitude));
            context.read<LocationProvider>().selectFavoriteLocation(location);
          },
        );
      },
    );
  }

  /// Moves camera to specified target coordinates
  void _moveToLocation(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 15.0),
    );
  }

  /// Handles fetching device location and animating camera
  Future<void> _handleMyLocation(LocationProvider provider) async {
    final position = await provider.getCurrentLocation();
    if (position != null) {
      _moveToLocation(LatLng(position.latitude, position.longitude));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Current location updated: Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          // Combine favorite markers with current location marker if available
          final Set<Marker> allMarkers = _createFavoriteMarkers();

          if (locationProvider.currentPosition != null) {
            allMarkers.add(
              Marker(
                markerId: const MarkerId('current_user_location'),
                position: LatLng(
                  locationProvider.currentPosition!.latitude,
                  locationProvider.currentPosition!.longitude,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
                infoWindow: const InfoWindow(
                  title: 'My Location',
                  snippet: 'Device real position',
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Google Map View with bottom padding so native controls shift up
              GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                markers: allMarkers,
                zoomControlsEnabled: true,
                padding: const EdgeInsets.only(bottom: 90.0),
                myLocationEnabled: locationProvider.currentPosition != null,
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),

              // Custom Zoom In & Zoom Out Buttons above bottom action bar
              Positioned(
                right: 16,
                bottom: 95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      elevation: 4,
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_btn',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      elevation: 4,
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),

              // Loading overlay when fetching location
              if (locationProvider.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Fetching current location...',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Action Buttons Overlay
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // My Location Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.my_location),
                            label: const Text(
                              '📍 My Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: locationProvider.isLoading
                                ? null
                                : () => _handleMyLocation(locationProvider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Favorite Locations Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.star),
                            label: const Text(
                              '📍 Favorite Locations',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _showFavoriteLocationsList,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
