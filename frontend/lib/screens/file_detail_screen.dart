import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/file_item.dart';
import '../providers/location_provider.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import '../utils/ui_constants.dart';
import '../animations/lottie_animations.dart';
import '../animations/screen_transitions.dart';
import '../widgets/error_display.dart';

class FileDetailScreen extends StatefulWidget {
  final FileItem fileItem;

  const FileDetailScreen({
    Key? key,
    required this.fileItem,
  }) : super(key: key);

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDownloading = false;
  bool _isDownloadSuccess = false;
  String? _error;
  File? _downloadedFile;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: UIConstants.mediumAnimationDuration,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final userLocation = locationProvider.currentLocation;

    // Calculate distance
    final double distance = userLocation != null
        ? widget.fileItem.distanceTo(userLocation)
        : double.infinity;
    
    // Check if user is within range
    final bool isWithinRange = FileUtils.isWithinRange(distance);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Details'),
      ),
      body: AnimatedScreenTransition(
        animation: _animationController,
        beginOffset: const Offset(0, 0.1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File icon animation
              Center(
                child: Hero(
                  tag: 'file_${widget.fileItem.id}',
                  child: LottieAnimations.pulseAnimation(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FileUtils.getFileIcon(widget.fileItem.name),
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // File name and description
              Text(
                widget.fileItem.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.fileItem.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // File metadata
              _buildInfoRow(
                icon: Icons.insert_drive_file,
                title: 'Size',
                value: FileUtils.formatFileSize(widget.fileItem.size),
              ),
              _buildInfoRow(
                icon: Icons.calendar_today,
                title: 'Uploaded',
                value: FileUtils.formatDateTime(widget.fileItem.uploadTime),
              ),
              _buildInfoRow(
                icon: Icons.timer,
                title: 'Available for',
                value: FileUtils.formatTimeRemaining(
                  widget.fileItem.uploadTime,
                  widget.fileItem.retentionPeriod,
                ),
              ),
              _buildInfoRow(
                icon: Icons.place,
                title: 'Distance',
                value: userLocation != null
                    ? FileUtils.formatDistance(distance)
                    : 'Unknown',
              ),
              const SizedBox(height: 40),
              
              // Download section
              Center(
                child: _buildDownloadSection(isWithinRange, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(bool isWithinRange, BuildContext context) {
    if (_isDownloading) {
      return Column(
        children: [
          LottieAnimations.download(width: 150, height: 150),
          const SizedBox(height: 16),
          const Text(
            'Downloading file...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      );
    } else if (_isDownloadSuccess) {
      return Column(
        children: [
          LottieAnimations.success(width: 150, height: 150),
          const SizedBox(height: 16),
          const Text(
            'Download completed!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (_downloadedFile != null) ...[
            const SizedBox(height: 16),
            Text(
              'Saved to: ${_downloadedFile!.path}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    } else if (_error != null) {
      return ErrorDisplay(
        message: 'Error: $_error',
        onRetry: () => setState(() => _error = null),
        animationSize: 150,
      );
    } else {
      return Column(
        children: [
          LottieAnimations.pulseAnimation(
            child: ElevatedButton.icon(
              onPressed: isWithinRange ? () => _downloadFile(context) : null,
              icon: const Icon(Icons.file_download),
              label: const Text(
                'Download File',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: UIConstants.buttonShape,
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!isWithinRange)
            const Text(
              'You must be within 100 meters to download this file',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      );
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });
    
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    
    try {
      if (locationProvider.currentLocation == null) {
        throw Exception('Location not available');
      }
      
      final file = await fileProvider.downloadFile(
        widget.fileItem,
        locationProvider.currentLocation!,
      );
      
      if (file != null) {
        setState(() {
          _isDownloading = false;
          _isDownloadSuccess = true;
          _downloadedFile = file;
        });
      } else {
        setState(() {
          _isDownloading = false;
          _error = 'Download failed';
        });
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _error = e.toString();
      });
    }
  }

  // Removed redundant _getFileIcon method - now using FileUtils.getFileIcon
}