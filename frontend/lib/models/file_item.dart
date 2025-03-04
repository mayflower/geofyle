import 'package:latlong2/latlong.dart';

class FileItem {
  final String id;
  final String name;
  final String description;
  final double size;
  final DateTime uploadTime;
  final LatLng location;
  final String uploaderId;
  final Duration retentionPeriod;

  FileItem({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.uploadTime,
    required this.location,
    required this.uploaderId,
    required this.retentionPeriod,
  });

  double distanceTo(LatLng userLocation) {
    final Distance distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      location,
      userLocation,
    );
  }

  bool isWithinRange(LatLng userLocation, double maxDistance) {
    return distanceTo(userLocation) <= maxDistance;
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      size: json['size'].toDouble(),
      uploadTime: DateTime.parse(json['uploadTime']),
      location: LatLng(json['latitude'], json['longitude']),
      uploaderId: json['uploaderId'],
      retentionPeriod: Duration(hours: json['retentionHours'] ?? 24),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'size': size,
      'uploadTime': uploadTime.toIso8601String(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'uploaderId': uploaderId,
      'retentionHours': retentionPeriod.inHours,
    };
  }
}