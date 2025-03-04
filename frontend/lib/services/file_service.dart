import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_item.dart';
import '../utils/config.dart';

class FileService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String deviceId;

  FileService({required this.deviceId});

  Future<List<FileItem>> getNearbyFiles(LatLng location, double radius) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/files/nearby?latitude=${location.latitude}&longitude=${location.longitude}&radius=$radius',
      ),
      headers: {'Device-ID': deviceId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => FileItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load nearby files');
    }
  }

  Future<FileItem> uploadFile(
    File file,
    String description,
    LatLng location,
    Duration retentionPeriod,
  ) async {
    final fileBytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/files/upload'),
    );

    request.fields['description'] = description;
    request.fields['latitude'] = location.latitude.toString();
    request.fields['longitude'] = location.longitude.toString();
    request.fields['retentionHours'] = retentionPeriod.inHours.toString();
    request.headers['Device-ID'] = deviceId;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return FileItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  Future<File> downloadFile(FileItem fileItem) async {
    final response = await http.get(
      Uri.parse('$baseUrl/files/download/${fileItem.id}'),
      headers: {'Device-ID': deviceId},
    );

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${fileItem.name}';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download file');
    }
  }

  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return result.files.single;
    }
    return null;
  }
}