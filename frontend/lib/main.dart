import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/file_item.dart';
import 'services/api_service.dart';

void main() {
  runApp(const BondlyApp());
}

class BondlyApp extends StatelessWidget {
  const BondlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bondly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
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
  bool _isLoadingHealth = true;
  bool _isLoadingFiles = true;
  bool _isUploading = false;
  Map<String, dynamic>? _healthData;
  List<FileItem> _files = [];
  String? _statusError;

  // Upload Form State
  final TextEditingController _titleController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _fetchHealth(),
      _fetchFiles(),
    ]);
  }

  Future<void> _fetchHealth() async {
    setState(() {
      _isLoadingHealth = true;
      _statusError = null;
    });
    try {
      final health = await ApiService.checkHealth();
      if (mounted) {
        setState(() {
          _healthData = health;
          _isLoadingHealth = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusError = e.toString();
          _isLoadingHealth = false;
        });
      }
    }
  }

  Future<void> _fetchFiles() async {
    setState(() => _isLoadingFiles = true);
    try {
      final files = await ApiService.fetchFiles();
      if (mounted) {
        setState(() {
          _files = files;
          _isLoadingFiles = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingFiles = false);
      }
    }
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
      final uploaded = await ApiService.uploadFile(
        bytes: _selectedFile!.bytes!,
        fileName: _selectedFile!.name,
        title: title,
      );

      _showSnackbar('File "${uploaded.title}" uploaded successfully!');
      setState(() {
        _selectedFile = null;
        _titleController.clear();
      });
      await _fetchFiles();
    } catch (e) {
      _showSnackbar('Upload failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // Quick 1-click test upload using a sample PNG
  Future<void> _uploadDemoImage() async {
    setState(() => _isUploading = true);
    try {
      // 1x1 transparent PNG sample bytes
      final sampleBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final uploaded = await ApiService.uploadFile(
        bytes: sampleBytes,
        fileName: 'demo_sample_${DateTime.now().millisecondsSinceEpoch}.png',
        title: 'Demo Test Image',
      );

      _showSnackbar('Demo image "${uploaded.title}" uploaded successfully!');
      await _fetchFiles();
    } catch (e) {
      _showSnackbar('Upload demo failed: $e', isError: true);
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
        content: Text('Are you sure you want to delete "${file.title}"?'),
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
        final success = await ApiService.deleteFile(file.id);
        if (success) {
          _showSnackbar('File deleted.');
          await _fetchFiles();
        } else {
          _showSnackbar('Could not delete file.', isError: true);
        }
      } catch (e) {
        _showSnackbar('Error deleting: $e', isError: true);
      }
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApiOnline = _healthData != null && _healthData!['status'] == 'ok';
    final dbConnected = _healthData?['database']?['connected'] == true;
    final cloudinaryConfigured = _healthData?['cloudinary']?['configured'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.hub_rounded,
                color: Theme.of(context).colorScheme.primary,
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
                    'Flutter • Express • PostgreSQL • Cloudinary',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live API Status Badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: CircleAvatar(
                radius: 5,
                backgroundColor: isApiOnline ? Colors.green : Colors.red,
              ),
              label: Text(
                isApiOnline ? 'API Online' : 'API Offline',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: isApiOnline ? Colors.green.shade50 : Colors.red.shade50,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshAll,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // System Architecture / Health Card
                _buildSystemStatusCard(isApiOnline, dbConnected, cloudinaryConfigured),
                const SizedBox(height: 16),

                // File Upload Card
                _buildUploadCard(),
                const SizedBox(height: 24),

                // Uploaded Files Gallery Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Processed Files (${_files.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_isLoadingFiles)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // File Grid or Empty State
                _buildFilesView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(
      bool isApiOnline, bool dbConnected, bool cloudinaryConfigured) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard_customize_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stack Status & Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (_isLoadingHealth)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (_statusError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Note: $_statusError',
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildServicePill(
                    title: 'Express API',
                    subtitle: isApiOnline ? 'Port 5000' : 'Offline',
                    icon: Icons.api,
                    color: isApiOnline ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServicePill(
                    title: 'PostgreSQL (pg)',
                    subtitle: dbConnected ? 'Active' : 'Fallback / Pending',
                    icon: Icons.storage,
                    color: dbConnected ? Colors.green : Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServicePill(
                    title: 'Cloudinary',
                    subtitle: cloudinaryConfigured ? 'Configured' : 'Dev / Demo Mode',
                    icon: Icons.cloud_upload_outlined,
                    color: cloudinaryConfigured ? Colors.green : Colors.blue,
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
                Text(
                  'Upload & Process File',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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

  Widget _buildFilesView() {
    if (_files.isEmpty) {
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
                'No files uploaded yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload an image or document above or click "1-Click Demo Upload" to test the pipeline.',
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
          itemCount: _files.length,
          itemBuilder: (context, index) {
            final file = _files[index];
            return _buildFileCard(file);
          },
        );
      },
    );
  }

  Widget _buildFileCard(FileItem file) {
    final previewUrl = file.thumbnailUrl ?? file.fileUrl;
    final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
      (file.format ?? '').toLowerCase(),
    ) || previewUrl.contains('image');

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
                      previewUrl,
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
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (file.format ?? 'FILE').toUpperCase(),
                        style: TextStyle(
                          color: Colors.indigo.shade800,
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
                      tooltip: 'Copy Cloudinary URL',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: file.fileUrl));
                        _showSnackbar('URL copied to clipboard!');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: 'Delete File',
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
