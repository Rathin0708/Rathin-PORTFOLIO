import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../utils/app_theme.dart';
import '../../services/admin_service.dart';
import '../../services/file_upload_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _resumeUrlController = TextEditingController();
  final _profileImageController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingProfileImage = false;
  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('profile')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? 'Rathin';
        _taglineController.text =
            data['tagline'] ?? 'Flutter Developer | UI/UX Enthusiast';
        _emailController.text = data['email'] ?? 'rathin007008@gmail.com';
        _phoneController.text = data['phone'] ?? '+91 7395837797';
        _locationController.text =
            data['location'] ?? 'Chennai, Tamil Nadu, India';
        _resumeUrlController.text = data['resumeUrl'] ?? '';
        _profileImageController.text = data['profileImage'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'tagline': _taglineController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'resumeUrl': _resumeUrlController.text.trim(),
        'profileImage': _profileImageController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AdminService.currentUser?.email,
      };

      await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('profile')
          .set(profileData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadProfileImage() async {
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Upload Profile Image'),
            content: Text(
                kIsWeb
                    ? 'Choose an image file from your computer'
                    : 'Choose an option to upload your profile image'
            ),
            actions: [
              if (!kIsWeb) ...[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _pickImageFromCamera();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('Camera'),
                    ],
              ),
            ),
          ],
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _pickImageFromGallery();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(kIsWeb ? Icons.file_upload : Icons.photo_library),
                const SizedBox(width: 8),
                Text(kIsWeb ? 'Choose File' : 'Gallery'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isUploadingProfileImage = true);

    try {
      final pickedFile = await FileUploadService.pickImageFromCamera();
      if (pickedFile != null) {
        final fileName = FileUploadService.generateFileName(pickedFile.name);
        String? downloadUrl;

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          downloadUrl = await FileUploadService.uploadProfileImage(
            fileName: fileName,
            bytes: bytes,
          );
        } else {
          final file = File(pickedFile.path);
          downloadUrl = await FileUploadService.uploadProfileImage(
            fileName: fileName,
            file: file,
          );
        }

        if (downloadUrl case final String url when url.isNotEmpty) {
          setState(() {
            _profileImageController.text = url;
          });

          // Auto-save profile data to Firebase immediately
          await _saveProfileImageToFirestore(url);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '✅ Profile image uploaded and updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to get download URL');
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingProfileImage = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isUploadingProfileImage = true);

    try {
      final pickedFile = await FileUploadService.pickImageFromGallery();
      if (pickedFile != null) {
        final fileName = FileUploadService.generateFileName(pickedFile.name);
        String? downloadUrl;

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          downloadUrl = await FileUploadService.uploadProfileImage(
            fileName: fileName,
            bytes: bytes,
          );
        } else {
          final file = File(pickedFile.path);
          downloadUrl = await FileUploadService.uploadProfileImage(
            fileName: fileName,
            file: file,
          );
        }

        if (downloadUrl case final String url when url.isNotEmpty) {
          setState(() {
            _profileImageController.text = url;
          });

          // Auto-save profile data to Firebase immediately
          await _saveProfileImageToFirestore(url);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '✅ Profile image uploaded and updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to get download URL');
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingProfileImage = false);
      }
    }
  }

  // New method to save only profile image to Firestore immediately
  Future<void> _saveProfileImageToFirestore(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('profile')
          .set({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AdminService.currentUser?.email ?? 'admin',
      }, SetOptions(merge: true));

      print('✅ Profile image saved to Firestore: $imageUrl');
    } catch (e) {
      print('❌ Error saving profile image to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _uploadResume() async {
    setState(() => _isUploadingResume = true);

    try {
      final pickedFile = await FileUploadService.pickDocumentResume();
      if (pickedFile != null) {
        final fileName = FileUploadService.generateFileName(pickedFile.name);
        String? downloadUrl;

        if (kIsWeb) {
          downloadUrl = await FileUploadService.uploadResume(
            fileName: fileName,
            bytes: pickedFile.bytes,
          );
        } else {
          final file = File(pickedFile.path!);
          downloadUrl = await FileUploadService.uploadResume(
            fileName: fileName,
            file: file,
          );
        }

        if (downloadUrl case final String url when url.isNotEmpty) {
          setState(() {
            _resumeUrlController.text = url;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Resume uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to get download URL');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error uploading resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploadingResume = false);
    }
  }

  Future<void> _testResumeDownload() async {
    try {
      final Uri url = Uri.parse(_resumeUrlController.text);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error opening resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
                ),
              ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildSectionHeader(
                    'Personal Information',
                    Icons.person,
                    'Update your basic profile details',
                  ),
                ),
                const SizedBox(height: 24),

                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: _buildTextFormField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) =>
                          value?.isEmpty == true ? 'Name is required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: _buildTextFormField(
                          controller: _taglineController,
                          label: 'Professional Tagline',
                          icon: Icons.work_outline,
                          validator: (value) =>
                          value?.isEmpty == true ? 'Tagline is required' : null,
                        ),
                      ),
                      const SizedBox(height: 32),

                      FadeInUp(
                        duration: const Duration(milliseconds: 900),
                        child: _buildSectionHeader(
                          'Contact Information',
                          Icons.contact_mail,
                          'Update your contact details',
                        ),
                      ),
                      const SizedBox(height: 24),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: _buildTextFormField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty == true)
                              return 'Email is required';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value!)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1100),
                        child: _buildTextFormField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: _buildTextFormField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(height: 32),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: _buildSectionHeader(
                          'Assets & Media',
                          Icons.image,
                          'Update profile image and resume',
                        ),
                      ),
                      const SizedBox(height: 24),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFormField(
                                    controller: _profileImageController,
                                    label: 'Profile Image URL',
                                    icon: Icons.image_outlined,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _isUploadingProfileImage
                                      ? null
                                      : _uploadProfileImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: _isUploadingProfileImage
                                      ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Uploading...'),
                                    ],
                                  )
                                      : const Text('Upload Image'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _profileImageController.text.isNotEmpty
                                ? Container(
                              margin: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: _profileImageController.text,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                ),
                              ),
                            )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFormField(
                                    controller: _resumeUrlController,
                                    label: 'Resume URL',
                                    icon: Icons.description_outlined,
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _isUploadingResume
                                      ? null
                                      : _uploadResume,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: _isUploadingResume
                                      ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Uploading...'),
                                    ],
                                  )
                                      : const Text('Upload Resume'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _resumeUrlController.text.isNotEmpty
                                ? Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Resume Uploaded',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Click download button to test',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _testResumeDownload(),
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Test Download',
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isSaving
                                ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Saving...'),
                              ],
                            )
                                : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text('Save Profile',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _resumeUrlController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }
}