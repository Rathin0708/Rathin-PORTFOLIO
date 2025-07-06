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
      final String path = 'profile_images/$fileName';
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

      print('✅ Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading profile image: $e');
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
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          print('❌ Camera permission denied');
          return null;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        print('✅ Image captured from camera: ${image.path}');
      }

      return image;
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      return null;
    }
  }

  // Pick Image from Gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          print('❌ Photos permission denied');
          return null;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        print('✅ Image selected from gallery: ${image.path}');
      }

      return image;
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      return null;
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
}