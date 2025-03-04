import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/location_provider.dart';
import '../providers/file_provider.dart';
import '../animations/lottie_animations.dart';
import '../animations/screen_transitions.dart';
import '../utils/file_utils.dart';
import '../utils/ui_constants.dart';
import '../widgets/error_display.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  PlatformFile? _selectedFile;
  final TextEditingController _descriptionController = TextEditingController();
  final List<int> _retentionOptions = [1, 24, 48, 72, 168]; // Hours (1h, 1d, 2d, 3d, 7d)
  int _selectedRetention = 24; // Default 24 hours
  
  bool _isUploading = false;
  bool _isUploadSuccess = false;
  String? _error;
  
  bool get _isFormValid => _selectedFile != null && 
                          _descriptionController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: UIConstants.longAnimationDuration,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
      ),
      body: AnimatedScreenTransition(
        animation: _animationController,
        child: SingleChildScrollView(
          padding: UIConstants.containerPadding,
          child: _buildContent(),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAnimations.upload(width: 200, height: 200),
          const SizedBox(height: 24),
          const Text(
            'Uploading file...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      );
    } else if (_isUploadSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAnimations.success(width: 200, height: 200),
          const SizedBox(height: 24),
          const Text(
            'File uploaded successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    } else if (_error != null) {
      return ErrorDisplay(
        message: 'Error: $_error',
        onRetry: () => setState(() => _error = null),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: LottieAnimations.pulseAnimation(
              child: _selectedFile == null
                  ? _buildFilePickerPlaceholder()
                  : _buildSelectedFileInfo(),
            ),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter a description for your file',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          
          Text(
            'File Retention Period',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            children: _retentionOptions.map((hours) {
              final isSelected = hours == _selectedRetention;
              final String label = _formatRetentionLabel(hours);
              
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedRetention = hours;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: _isFormValid ? _uploadFile : null,
            style: ElevatedButton.styleFrom(
              padding: UIConstants.buttonPadding,
              shape: UIConstants.buttonShape,
            ),
            child: const Text(
              'Upload File',
              style: UIConstants.subtitleTextStyle,
            ),
          ),
        ],
      );
    }
  }
  
  Widget _buildFilePickerPlaceholder() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 64,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to select a file',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedFileInfo() {
    final fileName = _selectedFile!.name;
    final fileSize = FileUtils.formatFileSize(_selectedFile!.size.toDouble());
    final IconData fileIcon = FileUtils.getFileIcon(fileName);
    
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fileIcon,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileSize,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickFile,
              child: const Text('Change file'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickFile() async {
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    final result = await fileProvider.pickFile();
    
    if (result != null) {
      setState(() {
        _selectedFile = result;
      });
    }
  }
  
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    
    setState(() {
      _isUploading = true;
      _error = null;
    });
    
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    
    try {
      if (locationProvider.currentLocation == null) {
        throw Exception('Location not available');
      }
      
      final result = await fileProvider.uploadFile(
        _selectedFile!,
        _descriptionController.text,
        locationProvider.currentLocation!,
        Duration(hours: _selectedRetention),
      );
      
      if (result != null) {
        setState(() {
          _isUploading = false;
          _isUploadSuccess = true;
        });
      } else {
        setState(() {
          _isUploading = false;
          _error = 'Upload failed';
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _error = e.toString();
      });
    }
  }
  
  String _formatRetentionLabel(int hours) {
    if (hours < 24) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final days = hours ~/ 24;
      return '$days day${days > 1 ? 's' : ''}';
    }
  }
  
  // Removed redundant _formatFileSize and _getFileIcon methods - now using FileUtils utility methods
}