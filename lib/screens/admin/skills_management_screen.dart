import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../services/admin_service.dart';
import '../../models/skill_model.dart';
import '../../utils/app_theme.dart';

class SkillsManagementScreen extends StatefulWidget {
  const SkillsManagementScreen({super.key});

  @override
  State<SkillsManagementScreen> createState() => _SkillsManagementScreenState();
}

class _SkillsManagementScreenState extends State<SkillsManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SkillModel> _skills = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSkills();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await AdminService.getSkills();
      setState(() {
        _skills = skills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load skills');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddSkillDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Skill',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildBody(),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_skills.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSkills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _skills.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildSkillCard(_skills[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Icon(
              Icons.star_outline,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'No Skills Added Yet',
              style: AppTheme.headingStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Add your first skill to get started',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 600),
            child: ElevatedButton.icon(
              onPressed: _showAddSkillDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Skill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillModel skill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    skill.iconEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        skill.category,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSkillDialog(skill);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(skill);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (skill.description != null) ...[
              const SizedBox(height: 12),
              Text(
                skill.description!,
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proficiency',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: skill.proficiency / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProficiencyColor(skill.proficiency),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${skill.proficiency}%',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getProficiencyColor(skill.proficiency),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (skill.tags.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: skill.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 10,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProficiencyColor(int proficiency) {
    if (proficiency >= 80) return Colors.green;
    if (proficiency >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showAddSkillDialog() {
    _showSkillDialog(null);
  }

  void _showEditSkillDialog(SkillModel skill) {
    _showSkillDialog(skill);
  }

  void _showSkillDialog(SkillModel? skill) {
    final isEditing = skill != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Skill' : 'Add Skill'),
        content: SizedBox(
          width: 400,
          child: FormBuilder(
            key: _formKey,
            initialValue: isEditing ? {
              'name': skill.name,
              'category': skill.category,
              'proficiency': skill.proficiency.toDouble(),
              'description': skill.description,
              'tags': skill.tags.join(', '),
            } : {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Skill Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<String>(
                  name: 'category',
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(),
                  items: SkillModel.categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                FormBuilderSlider(
                  name: 'proficiency',
                  decoration: const InputDecoration(
                    labelText: 'Proficiency Level',
                  ),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  initialValue: isEditing ? skill.proficiency.toDouble() : 50.0,
                  valueTransformer: (value) => value?.round(),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'description',
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'tags',
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., mobile, frontend, backend',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveSkill(skill),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSkill(SkillModel? existingSkill) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final skill = SkillModel(
        id: existingSkill?.id,
        name: formData['name'],
        category: formData['category'],
        proficiency: formData['proficiency'],
        description: formData['description']?.isEmpty == true ? null : formData['description'],
        tags: formData['tags']?.isEmpty == true
            ? <String>[]
            : formData['tags'].split(',').map((tag) => tag.trim()).toList(),
        createdAt: existingSkill?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (existingSkill != null) {
        success = await AdminService.updateSkill(existingSkill.id!, skill);
        await AdminService.logAdminAction('update_skill', {
          'skillId': existingSkill.id,
          'skillName': skill.name,
        });
      } else {
        success = await AdminService.addSkill(skill);
        await AdminService.logAdminAction('add_skill', {
          'skillName': skill.name,
          'category': skill.category,
        });
      }

      if (success) {
        Navigator.pop(context);
        _loadSkills();
        _showSuccessSnackBar(
          existingSkill != null ? 'Skill updated successfully' : 'Skill added successfully'
        );
      } else {
        _showErrorSnackBar('Failed to save skill');
      }
    }
  }

  void _showDeleteConfirmation(SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteSkill(skill),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSkill(SkillModel skill) async {
    final success = await AdminService.deleteSkill(skill.id!);

    if (success) {
      await AdminService.logAdminAction('delete_skill', {
        'skillId': skill.id,
        'skillName': skill.name,
      });

      Navigator.pop(context);
      _loadSkills();
      _showSuccessSnackBar('Skill deleted successfully');
    } else {
      _showErrorSnackBar('Failed to delete skill');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
