import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/file_item.dart';

class ApiService {
  // Base URL for the Express API
  // On desktop / web: http://localhost:5000
  // On Android emulator: http://10.0.2.2:5000
  static String baseUrl = 'http://localhost:5000';

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {
        'status': 'error',
        'message': 'HTTP ${response.statusCode}',
        'database': {'connected': false},
        'cloudinary': {'configured': false},
      };
    } catch (e) {
      return {
        'status': 'offline',
        'message': e.toString(),
        'database': {'connected': false},
        'cloudinary': {'configured': false},
      };
    }
  }

  static Future<List<FileItem>> fetchFiles() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/files'))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List list = data['data'] as List? ?? [];
      return list.map((item) => FileItem.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load files: ${response.statusCode}');
    }
  }

  static Future<FileItem> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String title,
  }) async {
    final uri = Uri.parse('$baseUrl/api/files/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ),
    );

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return FileItem.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      try {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Upload failed with status ${response.statusCode}');
      } catch (_) {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    }
  }

  static Future<bool> deleteFile(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/api/files/$id'))
        .timeout(const Duration(seconds: 6));
    return response.statusCode == 200;
  }
}
