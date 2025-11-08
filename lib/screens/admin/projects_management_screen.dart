import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_service.dart';

class ProjectsManagementScreen extends StatefulWidget {
  const ProjectsManagementScreen({super.key});

  @override
  State<ProjectsManagementScreen> createState() =>
      _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState extends State<ProjectsManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _liveUrlController = TextEditingController();
  final _technologyController = TextEditingController();

  List<String> _technologies = [];
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isFeatured = false;
  String? _editingProjectId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _projects = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final projectData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'githubUrl': _githubUrlController.text.trim(),
        'liveUrl': _liveUrlController.text
            .trim()
            .isEmpty
            ? null
            : _liveUrlController.text.trim(),
        'technologies': _technologies,
        'isFeatured': _isFeatured,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': AdminService.currentUser?.email,
      };

      if (_editingProjectId != null) {
        // Update existing project
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(_editingProjectId)
            .update(projectData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Project updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new project
        projectData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('projects')
            .add(projectData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Project added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _clearForm();
      await _loadProjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error saving project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _githubUrlController.clear();
    _liveUrlController.clear();
    _technologyController.clear();
    setState(() {
      _technologies.clear();
      _isFeatured = false;
      _editingProjectId = null;
    });
  }

  void _editProject(Map<String, dynamic> project) {
    _titleController.text = project['title'] ?? '';
    _descriptionController.text = project['description'] ?? '';
    _imageUrlController.text = project['imageUrl'] ?? '';
    _githubUrlController.text = project['githubUrl'] ?? '';
    _liveUrlController.text = project['liveUrl'] ?? '';

    setState(() {
      _technologies = List<String>.from(project['technologies'] ?? []);
      _isFeatured = project['isFeatured'] ?? false;
      _editingProjectId = project['id'];
    });

    // Scroll to form
    Scrollable.ensureVisible(
      _formKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _deleteProject(String projectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Project'),
            content: const Text(
                'Are you sure you want to delete this project? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Project deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadProjects();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error deleting project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addTechnology() {
    final tech = _technologyController.text.trim();
    if (tech.isNotEmpty && !_technologies.contains(tech)) {
      setState(() {
        _technologies.add(tech);
        _technologyController.clear();
      });
    }
  }

  void _removeTechnology(String tech) {
    setState(() {
      _technologies.remove(tech);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects Management'),
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
              onPressed: _saveProject,
              icon: Icon(_editingProjectId != null ? Icons.edit : Icons.add),
              tooltip: _editingProjectId != null
                  ? 'Update Project'
                  : 'Add Project',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Form
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildProjectForm(),
              ),
              const SizedBox(height: 32),

              // Projects List
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildProjectsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _editingProjectId != null ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingProjectId != null
                            ? 'Edit Project'
                            : 'Add New Project',
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 20,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _editingProjectId != null
                            ? 'Update project details'
                            : 'Create a new portfolio project',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_editingProjectId != null)
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text('Cancel'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextFormField(
              controller: _titleController,
              label: 'Project Title',
              icon: Icons.title,
              validator: (value) =>
              value?.isEmpty == true
                  ? 'Title is required'
                  : null,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) =>
              value?.isEmpty == true
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _imageUrlController,
              label: 'Image URL',
              icon: Icons.image,
              validator: (value) =>
              value?.isEmpty == true
                  ? 'Image URL is required'
                  : null,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _githubUrlController,
              label: 'GitHub URL',
              icon: Icons.code,
              validator: (value) =>
              value?.isEmpty == true
                  ? 'GitHub URL is required'
                  : null,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _liveUrlController,
              label: 'Live URL (Optional)',
              icon: Icons.link,
            ),
            const SizedBox(height: 24),

            // Technologies Section
            Text(
              'Technologies',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _technologyController,
                    decoration: InputDecoration(
                      labelText: 'Add Technology',
                      hintText: 'e.g., Flutter, Firebase',
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
                    onFieldSubmitted: (_) => _addTechnology(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addTechnology,
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
            const SizedBox(height: 16),

            if (_technologies.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _technologies
                    .map((tech) => _buildTechChip(tech))
                    .toList(),
              ),

            const SizedBox(height: 24),

            // Featured Toggle
            Row(
              children: [
                Switch(
                  value: _isFeatured,
                  onChanged: (bool value) {
                    setState(() {
                      _isFeatured = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Featured Project',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProject,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Saving...'),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_editingProjectId != null ? Icons.edit : Icons.add,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _editingProjectId != null
                          ? 'Update Project'
                          : 'Add Project',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Projects (${_projects.length})',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your portfolio projects',
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
          const SizedBox(height: 24),

          if (_projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Icon(
                      Icons.folder_open, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No projects added yet',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first project using the form above',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _projects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final project = _projects[index];
                return _buildProjectCard(project);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: project['isFeatured'] == true
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          project['title'] ?? 'Untitled',
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        if (project['isFeatured'] == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project['description'] ?? '',
                      style: AppTheme.bodyStyle.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editProject(project),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Project',
                  ),
                  IconButton(
                    onPressed: () => _deleteProject(project['id']),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Project',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (project['technologies'] != null &&
              (project['technologies'] as List).isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (project['technologies'] as List<dynamic>)
                  .map((tech) =>
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      tech.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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

  Widget _buildTechChip(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tech,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTechnology(tech),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _githubUrlController.dispose();
    _liveUrlController.dispose();
    _technologyController.dispose();
    super.dispose();
  }
}