import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  String toString() =>
      'LocationResult(lat: $latitude, lng: $longitude, accuracy: ${accuracy.toStringAsFixed(1)}m)';
}

class LocationException implements Exception {
  final String message;
  final bool isServiceDisabled;
  final bool isPermanentlyDenied;

  LocationException(
    this.message, {
    this.isServiceDisabled = false,
    this.isPermanentlyDenied = false,
  });

  @override
  String toString() => message;
}

class LocationAndSelfieService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Determine and get real current GPS location with comprehensive permission handling
  Future<LocationResult> getCurrentRealLocation() async {
    // 1. Check if location services (GPS hardware) are turned on
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('⚠️ [LocationService] Location services are disabled on device.');
      throw LocationException(
        'GPS location service is turned off. Please turn on device location to verify attendance.',
        isServiceDisabled: true,
      );
    }

    // 2. Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    log('📍 [LocationService] Current location permission status: $permission');

    if (permission == LocationPermission.denied) {
      log('📍 [LocationService] Requesting location permission from user...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('⛔ [LocationService] Location permission was denied by user.');
        throw LocationException(
          'Location permission was denied. Please allow location access to record attendance.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('⛔ [LocationService] Location permission is permanently denied.');
      throw LocationException(
        'Location permission is permanently denied. Please enable it in system app settings.',
        isPermanentlyDenied: true,
      );
    }

    // 3. Acquire GPS position with high accuracy & fallback
    Position? position;
    try {
      log('📡 [LocationService] Acquiring current GPS position...');
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      log('⚠️ [LocationService] High accuracy position timed out or failed: $e. Attempting last known position...');
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (position == null) {
        throw LocationException(
          'Could not acquire GPS position. Please make sure you have clear sky visibility and try again.',
        );
      }
    }

    final result = LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );

    log('✅ [LocationService] Captured current GPS location: $result');
    return result;
  }

  /// Open device system location settings
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Open application permission settings
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Capture selfie using front camera
  Future<File?> captureSelfie() async {
    try {
      log('📸 [LocationService] Opening front camera for attendance selfie...');
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        final file = File(photo.path);
        final sizeBytes = await file.length();
        log('✅ [LocationService] Captured selfie: ${file.path} (${(sizeBytes / 1024).toStringAsFixed(1)} KB)');
        return file;
      }
      log('ℹ️ [LocationService] Selfie capture cancelled by user.');
      return null;
    } catch (e) {
      log('❌ [LocationService] Error capturing selfie: $e');
      throw Exception('Unable to capture selfie: $e');
    }
  }
}
