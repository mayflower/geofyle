import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/file_item.dart';
import '../providers/location_provider.dart';
import '../utils/file_utils.dart';
import '../animations/lottie_animations.dart';

class FileListItem extends StatelessWidget {
  final FileItem fileItem;
  final VoidCallback onTap;
  final bool animate;

  const FileListItem({
    Key? key,
    required this.fileItem,
    required this.onTap,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final userLocation = locationProvider.currentLocation;
    
    Widget listTile = ListTile(
      title: Text(
        fileItem.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fileItem.description),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(FileUtils.formatFileSize(fileItem.size)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14),
              const SizedBox(width: 4),
              Text(FileUtils.formatDateTime(fileItem.uploadTime)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.timer, size: 14),
              const SizedBox(width: 4),
              Text(
                FileUtils.formatTimeRemaining(
                  fileItem.uploadTime,
                  fileItem.retentionPeriod,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place,
            color: FileUtils.getDistanceColor(
              userLocation != null ? fileItem.distanceTo(userLocation) : double.infinity,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userLocation != null
                ? FileUtils.formatDistance(fileItem.distanceTo(userLocation))
                : 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onTap: onTap,
    );

    if (animate) {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: AnimatedPadding(
          padding: const EdgeInsets.all(4.0),
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: listTile,
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: listTile,
      );
    }
  }

  // Removed redundant _getDistanceColor method - now using FileUtils.getDistanceColor
}