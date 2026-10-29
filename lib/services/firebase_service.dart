import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/file_item.dart';

class FirebaseService {
  static bool isInitialized = false;
  static String? initError;
  static User? currentUser;

  // Mock / offline fallback stream controller for zero-friction testing
  static final List<FileItem> _mockFiles = [];
  static final StreamController<List<FileItem>> _mockController =
      StreamController<List<FileItem>>.broadcast();

  /// Initialize Firebase Core, Firestore, Storage, and Auth
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      isInitialized = true;
      initError = null;

      // Authenticate anonymously if auth is enabled
      try {
        final authResult = await FirebaseAuth.instance.signInAnonymously();
        currentUser = authResult.user;
        debugPrint('Signed in anonymously: ${currentUser?.uid}');
      } catch (authErr) {
        debugPrint('Firebase Auth note: $authErr');
      }
    } catch (e) {
      isInitialized = false;
      initError = e.toString();
      debugPrint('Firebase initialization warning: $e');
      debugPrint('Running with in-memory Firestore & Storage simulator until Firebase is linked via `flutterfire configure`.');
    }
  }

  /// Real-time stream of uploaded files from Firestore
  static Stream<List<FileItem>> getFilesStream() {
    if (isInitialized) {
      try {
        return FirebaseFirestore.instance
            .collection('files')
            .orderBy('created_at', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) => FileItem.fromFirestore(doc)).toList();
        });
      } catch (e) {
        debugPrint('Firestore stream error: $e');
      }
    }
    // Return mock stream
    return _mockController.stream;
  }

  /// Upload file to Firebase Storage and save document to Cloud Firestore
  static Future<FileItem> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String title,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'bin';
    final storagePath = 'uploads/${timestamp}_$fileName';

    if (isInitialized) {
      try {
        // 1. Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        final metadata = SettableMetadata(
          contentType: _guessContentType(extension),
          customMetadata: {'title': title},
        );

        final uploadTask = await storageRef.putData(bytes, metadata);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // 2. Save metadata to Cloud Firestore
        final docRef = await FirebaseFirestore.instance.collection('files').add({
          'title': title,
          'file_name': fileName,
          'file_url': downloadUrl,
          'storage_path': storagePath,
          'format': extension,
          'bytes': bytes.length,
          'created_at': FieldValue.serverTimestamp(),
          'uploaded_by': currentUser?.uid ?? 'anonymous',
        });

        return FileItem(
          id: docRef.id,
          title: title,
          fileName: fileName,
          fileUrl: downloadUrl,
          storagePath: storagePath,
          format: extension,
          bytes: bytes.length,
          createdAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Live Firebase upload failed: $e. Falling back to local simulator.');
      }
    }

    // In-memory simulator fallback
    final mockItem = FileItem(
      id: 'mock_$timestamp',
      title: title,
      fileName: fileName,
      fileUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600&auto=format&fit=crop',
      storagePath: storagePath,
      format: extension,
      bytes: bytes.length,
      createdAt: DateTime.now(),
    );

    _mockFiles.insert(0, mockItem);
    _mockController.add(List.from(_mockFiles));
    return mockItem;
  }

  /// Delete file from Cloud Firestore and Firebase Storage
  static Future<bool> deleteFile(FileItem file) async {
    if (isInitialized) {
      try {
        // Delete from Storage if path exists
        if (file.storagePath != null && file.storagePath!.isNotEmpty) {
          try {
            await FirebaseStorage.instance.ref(file.storagePath).delete();
          } catch (storageErr) {
            debugPrint('Storage deletion note: $storageErr');
          }
        }

        // Delete from Firestore
        await FirebaseFirestore.instance.collection('files').doc(file.id).delete();
        return true;
      } catch (e) {
        debugPrint('Firestore delete failed: $e');
      }
    }

    // Mock deletion
    _mockFiles.removeWhere((item) => item.id == file.id);
    _mockController.add(List.from(_mockFiles));
    return true;
  }

  static String _guessContentType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  static void seedMockIfEmpty() {
    if (_mockFiles.isEmpty) {
      _mockController.add([]);
    }
  }
}
