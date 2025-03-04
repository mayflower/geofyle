import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/location_provider.dart';
import '../providers/file_provider.dart';
import '../widgets/file_list_item.dart';
import '../widgets/map_file_marker.dart';
import '../widgets/user_location_marker.dart';
import '../animations/lottie_animations.dart';
import '../animations/route_transitions.dart';
import 'file_detail_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to animate when switching tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Delayed initialization to get location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }
  
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get location and then load files
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.initializeLocation();
    
    if (locationProvider.currentLocation != null) {
      final fileProvider = Provider.of<FileProvider>(context, listen: false);
      await fileProvider.loadNearbyFiles(locationProvider.currentLocation!);
      
      // Start periodic refresh of nearby files
      fileProvider.startPeriodicRefresh(locationProvider.currentLocation!);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Stop the periodic refresh when leaving this screen
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    fileProvider.stopPeriodicRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoFyle'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List View'),
            Tab(icon: Icon(Icons.map), text: 'Map View'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer2<LocationProvider, FileProvider>(
        builder: (context, locationProvider, fileProvider, child) {
          if (_isLoading) {
            return Center(
              child: LottieAnimations.loadingIndicator(),
            );
          }
          
          if (locationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieAnimations.error(width: 150, height: 150),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${locationProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (fileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieAnimations.error(width: 150, height: 150),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${fileProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (locationProvider.currentLocation == null) {
            return const Center(
              child: Text('Waiting for location...'),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListView(fileProvider, locationProvider.currentLocation!),
              _buildMapView(fileProvider, locationProvider.currentLocation!),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToUpload(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }
  
  Widget _buildListView(FileProvider fileProvider, LatLng userLocation) {
    final nearbyFiles = fileProvider.nearbyFiles;
    
    if (nearbyFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No files nearby',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a file or move closer to shared files',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: nearbyFiles.length,
        itemBuilder: (context, index) {
          final fileItem = nearbyFiles[index];
          // Use animation with a slight delay based on index
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: FileListItem(
              fileItem: fileItem,
              onTap: () => _navigateToDetail(context, fileItem),
              animate: true,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMapView(FileProvider fileProvider, LatLng userLocation) {
    final nearbyFiles = fileProvider.nearbyFiles;
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: 16,
        maxZoom: 18,
        minZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: userLocation,
              radius: 100, // 100 meters radius
              color: Colors.blue.withOpacity(0.2),
              borderColor: Colors.blue.withOpacity(0.7),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: nearbyFiles.map((fileItem) => Marker(
                  point: fileItem.location,
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _navigateToDetail(context, fileItem),
                    child: Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                )).toList()..add(
                  Marker(
                    point: userLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.person_pin,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
  
  void _navigateToDetail(BuildContext context, fileItem) {
    Navigator.push(
      context,
      SlideUpPageRoute(
        page: FileDetailScreen(fileItem: fileItem),
      ),
    );
  }
  
  void _navigateToUpload(BuildContext context) {
    Navigator.push(
      context,
      ScalePageRoute(
        page: const UploadScreen(),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    
    if (locationProvider.currentLocation != null) {
      await fileProvider.loadNearbyFiles(locationProvider.currentLocation!);
    }
  }
}