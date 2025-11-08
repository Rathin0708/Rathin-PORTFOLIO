import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _imagePicker = ImagePicker();

  // Upload Profile Image with multiple options
  static Future<String?> uploadProfileImage({
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      print('🚀 Starting profile image upload: $fileName');

      final String path = 'profile_images/$fileName';
      final Reference ref = _storage.ref().child(path);

      // Set metadata for better handling
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'profile_image',
        },
      );

      UploadTask uploadTask;
      if (kIsWeb && bytes != null) {
        print('📤 Web upload: ${bytes.length} bytes');
        uploadTask = ref.putData(bytes, metadata);
      } else if (file != null) {
        print('📤 Mobile upload: ${file.path}');
        uploadTask = ref.putFile(file, metadata);
      } else {
        throw Exception('No file or bytes provided');
      }

      // Monitor upload progress with better logging and timeout
      bool progressStarted = false;
      DateTime startTime = DateTime.now();

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) *
            100;
        final state = snapshot.state;

        if (snapshot.bytesTransferred > 0) {
          progressStarted = true;
        }

        print('📊 Upload progress: ${progress.toStringAsFixed(
            2)}% - State: $state');
        print('📈 Bytes: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');

        if (state == TaskState.error) {
          print('❌ Upload error detected in snapshot');
        }

        if (state == TaskState.success) {
          print('🎉 Upload completed successfully!');
        }
      }, onError: (error) {
        print('❌ Upload stream error: $error');
      });

      print('⏳ Waiting for upload completion...');

      // Add timeout for stuck uploads
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          print('⏰ Upload timeout - canceling task');
          uploadTask.cancel();
          throw Exception(
              'Upload timeout after 2 minutes. Please check your connection and Firebase Storage setup.');
        },
      );

      print('✅ Upload completed, getting download URL...');

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('🔗 Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      print('📋 Error type: ${e.runtimeType}');

      if (e.toString().contains('storage/unauthorized')) {
        print('🔒 Firebase Storage permission denied - check storage rules');
        throw Exception(
            'Permission denied. Please check Firebase Storage rules.');
      } else if (e.toString().contains('storage/retry-limit-exceeded')) {
        print('🔄 Upload retry limit exceeded');
        throw Exception(
            'Upload failed after multiple retries. Please try again.');
      } else if (e.toString().contains('TimeoutException')) {
        print('⏰ Upload timed out');
        throw Exception(
            'Upload timed out. Please check your internet connection.');
      }

      return null;
    }
  }

  // Upload Resume/Document with multiple formats
  static Future<String?> uploadResume({
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      final String path = 'resumes/$fileName';
      final Reference ref = _storage.ref().child(path);

      // Set metadata for better handling
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': 'resume',
        },
      );

      UploadTask uploadTask;
      if (kIsWeb && bytes != null) {
        uploadTask = ref.putData(bytes, metadata);
      } else if (file != null) {
        uploadTask = ref.putFile(file, metadata);
      } else {
        throw Exception('No file or bytes provided');
      }

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) *
            100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Resume uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading resume: $e');
      return null;
    }
  }

  // Upload Project Image
  static Future<String?> uploadProjectImage({
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      final String path = 'project_images/$fileName';
      final Reference ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb && bytes != null) {
        uploadTask = ref.putData(bytes);
      } else if (file != null) {
        uploadTask = ref.putFile(file);
      } else {
        throw Exception('No file or bytes provided');
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Project image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading project image: $e');
      return null;
    }
  }

  // Upload Certificate Image
  static Future<String?> uploadCertificateImage({
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      final String path = 'certificate_images/$fileName';
      final Reference ref = _storage.ref().child(path);

      UploadTask uploadTask;
      if (kIsWeb && bytes != null) {
        uploadTask = ref.putData(bytes);
      } else if (file != null) {
        uploadTask = ref.putFile(file);
      } else {
        throw Exception('No file or bytes provided');
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Certificate image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading certificate image: $e');
      return null;
    }
  }

  // Pick Image from Camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      if (!kIsWeb) {
        // Check camera permission for mobile platforms
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          print('❌ Camera permission denied');
          return null;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        print('✅ Image captured from camera: ${image.path}');

        // Validate file size (max 10MB)
        final bytes = await image.readAsBytes();
        if (!isFileSizeValid(bytes.length, 10)) {
          throw Exception('Image size is too large. Maximum size is 10MB.');
        }

        // Validate image format
        if (!isValidImageFile(image.name)) {
          throw Exception(
              'Invalid image format. Please use JPG, PNG, or WebP.');
        }
      }

      return image;
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      rethrow;
    }
  }

  // Pick Image from Gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        // For web, use file picker directly as it's more reliable
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.first.bytes != null) {
          final file = result.files.first;

          // Validate file size (max 10MB)
          if (!isFileSizeValid(file.size, 10)) {
            throw Exception('Image size is too large. Maximum size is 10MB.');
          }

          // Validate image format
          if (!isValidImageFile(file.name)) {
            throw Exception(
                'Invalid image format. Please use JPG, PNG, or WebP.');
          }

          print('✅ Image selected from web: ${file.name}');

          // Create XFile from PlatformFile for web
          return XFile.fromData(
            file.bytes!,
            name: file.name,
            mimeType: _getContentType(file.name),
          );
        }
        return null;
      } else {
        // For mobile platforms
        var permission = await Permission.photos.request();

        // For Android 13+ (API 33+), check specific permissions
        if (permission.isDenied) {
          try {
            permission = await Permission.storage.request();
          } catch (e) {
            print('Storage permission check failed: $e');
          }
        }

        if (!permission.isGranted) {
          print('❌ Photos permission denied');
          return null;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        print('✅ Image selected from gallery: ${image.path}');

        // Validate file size (max 10MB)
        final bytes = await image.readAsBytes();
        if (!isFileSizeValid(bytes.length, 10)) {
          throw Exception('Image size is too large. Maximum size is 10MB.');
        }

        // Validate image format
        if (!isValidImageFile(image.name)) {
          throw Exception(
              'Invalid image format. Please use JPG, PNG, or WebP.');
        }
      }

      return image;
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      rethrow;
    }
  }

  // Pick File (Documents, PDFs, etc.)
  static Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    FileType fileType = FileType.any,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: kIsWeb, // Load file data for web
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        print('✅ File selected: ${file.name} (${file.size} bytes)');
        return file;
      }

      return null;
    } catch (e) {
      print('❌ Error picking file: $e');
      return null;
    }
  }

  // Pick PDF Resume
  static Future<PlatformFile?> pickPDFResume() async {
    return await pickFile(
      fileType: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  // Pick Document Resume (PDF, DOC, DOCX)
  static Future<PlatformFile?> pickDocumentResume() async {
    return await pickFile(
      fileType: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
  }

  // Delete File from Storage
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print('✅ File deleted successfully: $downloadUrl');
      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  // Get File Extension from URL
  static String getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path
          .split('.')
          .last
          .toLowerCase();
    } catch (e) {
      return '';
    }
  }

  // Validate File Size (in MB)
  static bool isFileSizeValid(int sizeInBytes, int maxSizeMB) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeBytes;
  }

  // Validate Image File
  static bool isValidImageFile(String fileName) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName
        .split('.')
        .last
        .toLowerCase();
    return validExtensions.contains(extension);
  }

  // Validate Resume File
  static bool isValidResumeFile(String fileName) {
    final validExtensions = ['pdf', 'doc', 'docx'];
    final extension = fileName
        .split('.')
        .last
        .toLowerCase();
    return validExtensions.contains(extension);
  }

  // Generate Unique File Name
  static String generateFileName(String originalName) {
    final timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
    final extension = originalName
        .split('.')
        .last;
    return '${timestamp}_${originalName.replaceAll(' ', '_')}';
  }

  // Compress Image (Mobile only)
  static Future<File?> compressImage(File imageFile) async {
    try {
      if (kIsWeb) return imageFile;

      // Basic compression - you can add image compression package for better results
      return imageFile;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return imageFile;
    }
  }

  // Get Content Type based on file extension
  static String _getContentType(String fileName) {
    final extension = fileName
        .split('.')
        .last
        .toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}