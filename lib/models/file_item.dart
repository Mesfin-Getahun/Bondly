import 'package:cloud_firestore/cloud_firestore.dart';

class FileItem {
  final String id;
  final String title;
  final String fileName;
  final String fileUrl;
  final String? storagePath;
  final String? format;
  final int? bytes;
  final DateTime? createdAt;

  FileItem({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    this.storagePath,
    this.format,
    this.bytes,
    this.createdAt,
  });

  factory FileItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime? created;
    if (data['created_at'] is Timestamp) {
      created = (data['created_at'] as Timestamp).toDate();
    } else if (data['created_at'] is String) {
      created = DateTime.tryParse(data['created_at']);
    }

    return FileItem(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      fileName: data['file_name'] as String? ?? 'file',
      fileUrl: data['file_url'] as String? ?? '',
      storagePath: data['storage_path'] as String?,
      format: data['format'] as String?,
      bytes: data['bytes'] is int
          ? data['bytes'] as int
          : int.tryParse(data['bytes']?.toString() ?? '0'),
      createdAt: created,
    );
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem.fromMap(json['id']?.toString() ?? '', json);
  }

  factory FileItem.fromMap(String id, Map<String, dynamic> data) {
    DateTime? created;
    if (data['created_at'] is Timestamp) {
      created = (data['created_at'] as Timestamp).toDate();
    } else if (data['created_at'] is String) {
      created = DateTime.tryParse(data['created_at']);
    }

    return FileItem(
      id: id,
      title: data['title'] as String? ?? 'Untitled',
      fileName: data['file_name'] as String? ?? 'file',
      fileUrl: data['file_url'] as String? ?? '',
      storagePath: data['storage_path'] as String?,
      format: data['format'] as String?,
      bytes: data['bytes'] is int
          ? data['bytes'] as int
          : int.tryParse(data['bytes']?.toString() ?? '0'),
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'file_name': fileName,
      'file_url': fileUrl,
      'storage_path': storagePath,
      'format': format,
      'bytes': bytes,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  String get formattedSize {
    if (bytes == null || bytes == 0) return '0 B';
    if (bytes! < 1024) return '$bytes B';
    if (bytes! < 1024 * 1024) return '${(bytes! / 1024).toStringAsFixed(1)} KB';
    return '${(bytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
