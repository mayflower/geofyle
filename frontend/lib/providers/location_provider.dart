import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _error;

  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LocationProvider() {
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await _locationService.checkLocationPermission();
      if (!hasPermission) {
        _error = 'Location permission required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentLocation = await _locationService.getCurrentLocation();
      _setupLocationStream();
    } catch (e) {
      _error = 'Failed to get location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestLocationPermission() async {
    final granted = await _locationService.requestLocationPermission();
    if (granted) {
      await initializeLocation();
    }
    return granted;
  }

  void _setupLocationStream() {
    _locationService.getLocationStream().listen(
      (location) {
        _currentLocation = location;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Location stream error: $e';
        notifyListeners();
      },
    );
  }
}