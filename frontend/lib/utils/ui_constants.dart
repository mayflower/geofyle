import 'package:flutter/material.dart';

class UIConstants {
  // Card styling
  static final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  );
  static const cardElevation = 2.0;
  
  // Button styling
  static final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  );
  static const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  
  // Container styling
  static final containerRadius = BorderRadius.circular(16.0);
  static const containerPadding = EdgeInsets.all(16.0);
  
  // Animation durations
  static const shortAnimationDuration = Duration(milliseconds: 300);
  static const mediumAnimationDuration = Duration(milliseconds: 500);
  static const longAnimationDuration = Duration(milliseconds: 800);
  
  // Spacing constants
  static const smallSpacing = 8.0;
  static const mediumSpacing = 16.0;
  static const largeSpacing = 24.0;
  static const extraLargeSpacing = 32.0;
  
  // Text styles
  static const titleTextStyle = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.bold,
  );
  
  static const subtitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static const bodyTextStyle = TextStyle(
    fontSize: 14,
  );
  
  static const errorTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.red,
  );
}