import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/favorite_location.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  FavoriteLocation? _selectedFavoriteLocation;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FavoriteLocation? get selectedFavoriteLocation => _selectedFavoriteLocation;

  /// Fetches real current location using [LocationService]
  Future<Position?> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentPosition = position;
      _isLoading = false;
      notifyListeners();
      return position;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Sets the currently selected favorite location
  void selectFavoriteLocation(FavoriteLocation location) {
    _selectedFavoriteLocation = location;
    notifyListeners();
  }

  /// Clears any existing error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
