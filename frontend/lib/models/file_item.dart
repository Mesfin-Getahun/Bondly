class FileItem {
  final int id;
  final String title;
  final String fileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final String? publicId;
  final String? format;
  final int? bytes;
  final String? createdAt;

  FileItem({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    this.publicId,
    this.format,
    this.bytes,
    this.createdAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      fileName: json['file_name'] as String? ?? 'file',
      fileUrl: json['file_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      publicId: json['public_id'] as String?,
      format: json['format'] as String?,
      bytes: json['bytes'] is int
          ? json['bytes']
          : int.tryParse(json['bytes']?.toString() ?? '0'),
      createdAt: json['created_at'] as String?,
    );
  }

  String get formattedSize {
    if (bytes == null || bytes == 0) return '0 B';
    if (bytes! < 1024) return '$bytes B';
    if (bytes! < 1024 * 1024) return '${(bytes! / 1024).toStringAsFixed(1)} KB';
    return '${(bytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
