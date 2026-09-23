import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../presentation/utils/communes.dart';
import '../repositories/location_repository.dart';

enum LocationDetectionError { permissionDenied, serviceDisabled, timeout, unknown }

class LocationDetectionResult {
  const LocationDetectionResult.success(this.point) : error = null;
  const LocationDetectionResult.failure(this.error) : point = null;

  final LocationPoint? point;
  final LocationDetectionError? error;

  bool get isSuccess => point != null;
}

class LocationService {
  LocationService(this._locationRepository);

  final LocationRepository _locationRepository;

  Future<LocationDetectionResult> detectNearestLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationDetectionResult.failure(LocationDetectionError.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return const LocationDetectionResult.failure(LocationDetectionError.permissionDenied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 8)),
      );

      try {
        // Chemin principal : le backend connaît des milliers de vraies localités
        // (import GeoNames) -> bien plus précis que notre petite liste repli.
        final nearest = await _locationRepository.nearest(position.latitude, position.longitude);

        return LocationDetectionResult.success(LocationPoint(
          label: nearest.name,
          latitude: nearest.latitude,
          longitude: nearest.longitude,
          freeText: nearest.name,
        ));
      } catch (_) {
        // Repli si le backend est injoignable (offline, pas encore importé...) :
        // mieux vaut une réponse approximative qu'un échec total.
        return LocationDetectionResult.success(_nearestLocalPoint(position.latitude, position.longitude));
      }
    } catch (_) {
      return const LocationDetectionResult.failure(LocationDetectionError.timeout);
    }
  }

  LocationPoint _nearestLocalPoint(double latitude, double longitude) {
    LocationPoint nearest = allLocationPoints.first;
    double nearestDistance = double.infinity;

    for (final point in allLocationPoints) {
      final distance = Geolocator.distanceBetween(latitude, longitude, point.latitude, point.longitude);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = point;
      }
    }

    return nearest;
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.watch(locationRepositoryProvider)),
);
