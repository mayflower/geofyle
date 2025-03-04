import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';

class FileProvider with ChangeNotifier {
  final FileService _fileService;
  List<FileItem> _nearbyFiles = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  final double _maxDistance = 100.0; // 100 meters radius

  FileProvider(String deviceId)
      : _fileService = FileService(deviceId: deviceId);

  List<FileItem> get nearbyFiles => _nearbyFiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get maxDistance => _maxDistance;

  Future<void> loadNearbyFiles(LatLng location) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearbyFiles = await _fileService.getNearbyFiles(location, _maxDistance);
    } catch (e) {
      _error = 'Failed to load nearby files: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPeriodicRefresh(LatLng location) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadNearbyFiles(location),
    );
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<FileItem?> uploadFile(
    PlatformFile platformFile,
    String description,
    LatLng location,
    Duration retentionPeriod,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final file = File(platformFile.path!);
      final uploadedFile = await _fileService.uploadFile(
        file,
        description,
        location,
        retentionPeriod,
      );
      
      // Add to the list if within range
      if (uploadedFile.isWithinRange(location, _maxDistance)) {
        _nearbyFiles.add(uploadedFile);
      }
      
      _isLoading = false;
      notifyListeners();
      return uploadedFile;
    } catch (e) {
      _error = 'Failed to upload file: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<File?> downloadFile(FileItem fileItem, LatLng userLocation) async {
    // Check if the user is within range
    if (!fileItem.isWithinRange(userLocation, _maxDistance)) {
      _error = 'You must be within 100 meters to download this file';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final file = await _fileService.downloadFile(fileItem);
      _isLoading = false;
      notifyListeners();
      return file;
    } catch (e) {
      _error = 'Failed to download file: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<PlatformFile?> pickFile() async {
    return await _fileService.pickFile();
  }

  @override
  void dispose() {
    stopPeriodicRefresh();
    super.dispose();
  }
}