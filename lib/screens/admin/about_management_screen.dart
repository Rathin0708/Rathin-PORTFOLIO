import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_service.dart';

class AboutManagementScreen extends StatefulWidget {
  const AboutManagementScreen({super.key});

  @override
  State<AboutManagementScreen> createState() => _AboutManagementScreenState();
}

class _AboutManagementScreenState extends State<AboutManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _skillController = TextEditingController();

  List<String> _skills = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  Future<void> _loadAboutData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('about')
          .get();

      if (!mounted) return; // Check if widget is still mounted

      if (doc.exists) {
        final data = doc.data()!;
        _bioController.text = data['bio'] ??
            'Passionate Flutter developer with expertise in creating beautiful, '
                'cross-platform applications. I specialize in Firebase integration, '
                'state management, and delivering exceptional user experiences across '
                'mobile, web, and desktop platforms.';

        _skills = List<String>.from(data['skills'] ?? [
          'Flutter', 'Dart', 'Firebase', 'Provider', 'REST APIs',
          'Git', 'UI/UX Design', 'Responsive Design', 'State Management'
        ]);
      } else {
        // Default skills if no data exists
        _skills = [
          'Flutter', 'Dart', 'Firebase', 'Provider', 'REST APIs',
          'Git', 'UI/UX Design', 'Responsive Design', 'State Management'
        ];
      }
    } catch (e) {
      if (!mounted) return; // Check before showing SnackBar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading about data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAbout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final aboutData = {
        'bio': _bioController.text.trim(),
        'skills': _skills,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AdminService.currentUser?.email,
      };

      await FirebaseFirestore.instance
          .collection('portfolio_settings')
          .doc('about')
          .set(aboutData, SetOptions(merge: true));

      if (!mounted) return; // Check if widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ About section updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return; // Check before showing SnackBar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving about data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Management'),
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
              onPressed: _saveAbout,
              icon: const Icon(Icons.save),
              tooltip: 'Save About',
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
                    'Bio & Description',
                    Icons.info_outline,
                    'Write your professional bio and description',
                  ),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: TextFormField(
                    controller: _bioController,
                    maxLines: 8,
                    validator: (value) =>
                    value?.isEmpty == true
                        ? 'Bio is required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Professional Bio',
                      hintText: 'Write a compelling bio about yourself...',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor,
                            width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: _buildSectionHeader(
                    'Skills & Technologies',
                    Icons.star_outline,
                    'Add your technical skills and expertise',
                  ),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillController,
                          decoration: InputDecoration(
                            labelText: 'Add New Skill',
                            hintText: 'e.g., Flutter, React, Node.js',
                            prefixIcon: const Icon(Icons.code),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                          onFieldSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildSkillsGrid(),
                ),
                const SizedBox(height: 40),

                FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAbout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
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
                          Text('Save About', style: TextStyle(fontSize: 16)),
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

  Widget _buildSkillsGrid() {
    if (_skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.code_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No skills added yet',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first skill using the form above',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Skills (${_skills.length})',
          style: AppTheme.headingStyle.copyWith(
            fontSize: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}