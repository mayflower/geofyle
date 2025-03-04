import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileUtils {
  static String formatFileSize(double bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unit = 0;
    double size = bytes;
    
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unit]}';
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat('MMM d, y - h:mm a').format(dateTime);
    }
  }

  static String formatTimeRemaining(DateTime uploadTime, Duration retentionPeriod) {
    final expirationTime = uploadTime.add(retentionPeriod);
    final now = DateTime.now();
    final remaining = expirationTime.difference(now);

    if (remaining.isNegative) {
      return 'Expired';
    }

    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    } else {
      return '${remaining.inMinutes}m remaining';
    }
  }
  
  static Color getDistanceColor(double distance) {
    if (distance <= 50) {
      return Colors.green;
    } else if (distance <= 75) {
      return Colors.orange;
    } else if (distance <= 100) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
  
  static bool isWithinRange(double distance, [double maxRange = 100]) {
    return distance <= maxRange;
  }
  
  static IconData getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'm4a':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return Icons.video_file;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      case 'html':
      case 'css':
      case 'js':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }
}