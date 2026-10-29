import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/file_item.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const BondlyApp());
}

class BondlyApp extends StatelessWidget {
  const BondlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bondly Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9100), // Firebase Amber / Orange
          primary: const Color(0xFFFF8F00),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isUploading = false;
  final TextEditingController _titleController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    FirebaseService.seedMockIfEmpty();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          if (_titleController.text.trim().isEmpty) {
            _titleController.text = _selectedFile!.name.split('.').first;
          }
        });
      }
    } catch (e) {
      _showSnackbar('File picker error: $e', isError: true);
    }
  }

  Future<void> _uploadSelectedFile() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      _showSnackbar('Please select a file to upload.', isError: true);
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedFile!.name
        : _titleController.text.trim();

    setState(() => _isUploading = true);

    try {
      final uploaded = await FirebaseService.uploadFile(
        bytes: _selectedFile!.bytes!,
        fileName: _selectedFile!.name,
        title: title,
      );

      _showSnackbar('File "${uploaded.title}" uploaded to Firebase!');
      setState(() {
        _selectedFile = null;
        _titleController.clear();
      });
    } catch (e) {
      _showSnackbar('Upload failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _uploadDemoImage() async {
    setState(() => _isUploading = true);
    try {
      // 1x1 sample PNG bytes
      final sampleBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final uploaded = await FirebaseService.uploadFile(
        bytes: sampleBytes,
        fileName: 'demo_image_${DateTime.now().millisecondsSinceEpoch}.png',
        title: 'Demo Test Upload',
      );

      _showSnackbar('Demo "${uploaded.title}" saved to Firebase!');
    } catch (e) {
      _showSnackbar('Demo upload failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteFile(FileItem file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete "${file.title}" from Firebase Firestore & Storage?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await FirebaseService.deleteFile(file);
        if (success) {
          _showSnackbar('File deleted from Firebase.');
        } else {
          _showSnackbar('Could not delete file.', isError: true);
        }
      } catch (e) {
        _showSnackbar('Delete failed: $e', isError: true);
      }
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = FirebaseService.isInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9100).withAlpha(35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bondly',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Flutter • Cloud Firestore • Firebase Storage • Auth',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: CircleAvatar(
                radius: 5,
                backgroundColor: isInitialized ? Colors.green : const Color(0xFFE65100),
              ),
              label: Text(
                isInitialized ? 'Firebase Connected' : 'Firebase Ready (Demo Mode)',
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: isInitialized ? Colors.green.shade50 : Colors.orange.shade50,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // System Architecture / Firebase Status Card
              _buildFirebaseStatusCard(isInitialized),
              const SizedBox(height: 16),

              // Upload Card
              _buildUploadCard(),
              const SizedBox(height: 24),

              // Real-time Firestore Stream Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.stream_rounded, size: 20, color: Color(0xFFE65100)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cloud Firestore Stream',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          'Real-time Active',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Real-time Firestore Stream List
              StreamBuilder<List<FileItem>>(
                stream: FirebaseService.getFilesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final files = snapshot.data ?? [];
                  return _buildFilesView(files);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirebaseStatusCard(bool isInitialized) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Firebase Architecture & Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildServicePill(
                    title: 'Cloud Firestore',
                    subtitle: 'Real-time NoSQL DB',
                    icon: Icons.storage_rounded,
                    color: const Color(0xFFFFA000),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServicePill(
                    title: 'Firebase Storage',
                    subtitle: 'Secure File Storage',
                    icon: Icons.cloud_upload_rounded,
                    color: const Color(0xFF0288D1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServicePill(
                    title: 'Firebase Auth',
                    subtitle: 'Identity & Security',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF43A047),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePill({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Upload to Firebase Storage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isUploading ? null : _uploadDemoImage,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('1-Click Demo Upload'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_selectedFile == null ? 'Select File' : 'Change File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'File Title / Description',
                      hintText: _selectedFile?.name ?? 'Enter title...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed:
                      (_isUploading || _selectedFile == null) ? null : _uploadSelectedFile,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Selected: ${_selectedFile!.name} (${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB)',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilesView(List<FileItem> files) {
    if (files.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'No files in Firestore collection yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload an image or document above or click "1-Click Demo Upload" to test the Firebase real-time stream.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 450 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return _buildFileCard(file);
          },
        );
      },
    );
  }

  Widget _buildFileCard(FileItem file) {
    final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
      (file.format ?? '').toLowerCase(),
    ) || file.fileUrl.contains('image');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Preview
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              width: double.infinity,
              child: isImage
                  ? Image.network(
                      file.fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey.shade400),
                            const SizedBox(height: 4),
                            Text(
                              file.format?.toUpperCase() ?? 'FILE',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file, size: 48, color: Colors.grey.shade500),
                          const SizedBox(height: 6),
                          Text(
                            file.format?.toUpperCase() ?? 'FILE',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // Metadata and Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (file.format ?? 'FILE').toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${file.fileName} • ${file.formattedSize}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy Firebase Storage URL',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: file.fileUrl));
                        _showSnackbar('Download URL copied to clipboard!');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete Document & File',
                      onPressed: () => _deleteFile(file),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
