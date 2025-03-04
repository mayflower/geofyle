import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/location_provider.dart';
import '../animations/lottie_animations.dart';
import '../animations/route_transitions.dart';
import 'permission_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _animationController.forward();
    
    // Navigate to the next screen after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkLocationPermission();
      }
    });
  }
  
  void _checkLocationPermission() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    // Call initializeLocation instead which internally checks permissions
    await locationProvider.initializeLocation();
    
    if (locationProvider.error == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadePageRoute(page: const HomeScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadePageRoute(page: const PermissionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieAnimations.splash(
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            const Text(
              'GeoFyle',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share files based on your location',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}