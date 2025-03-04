import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/file_item.dart';
import '../animations/lottie_animations.dart';
import '../utils/file_utils.dart';

class MapFileMarker extends StatelessWidget {
  final FileItem fileItem;
  final LatLng userLocation;
  final VoidCallback onTap;

  const MapFileMarker({
    Key? key,
    required this.fileItem,
    required this.userLocation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = fileItem.distanceTo(userLocation);
    final isWithinRange = FileUtils.isWithinRange(distance);

    return MarkerLayer(
      markers: [
        Marker(
          point: fileItem.location,
          width: 60,
          height: 60,
          child: GestureDetector(
        onTap: onTap,
        child: LottieAnimations.pulseAnimation(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: FileUtils.getDistanceColor(distance).withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  FileUtils.getFileIcon(fileItem.name),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  fileItem.name.length > 10
                      ? '${fileItem.name.substring(0, 8)}...'
                      : fileItem.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: FileUtils.getDistanceColor(distance),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      ],
    );
  }

  // Removed redundant _getMarkerColor method - now using FileUtils.getDistanceColor
}