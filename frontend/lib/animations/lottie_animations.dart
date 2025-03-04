import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimations {
  static Widget splash({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/splash.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  static Widget locationPermission({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/location_permission.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  static Widget upload({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/upload.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  static Widget download({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/download.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  static Widget success({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/success.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: false,
    );
  }

  static Widget error({double? width, double? height}) {
    return Lottie.asset(
      'assets/lottie/error.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: false,
    );
  }

  static Widget loadingIndicator({double? width, double? height, Color? color}) {
    return SizedBox(
      width: width ?? 100,
      height: height ?? 100,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.blue,
        ),
      ),
    );
  }

  static Widget pulseAnimation({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.05),
      duration: const Duration(seconds: 1),
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {},
    );
  }
}