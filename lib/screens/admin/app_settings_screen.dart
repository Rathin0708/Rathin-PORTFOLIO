import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await AdminService.getAppSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            child: Text(
              'Application Settings',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 24,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSettingsCard(
              'Portfolio Information',
              [
                _buildSettingItem('App Name', _settings['appName'] ?? 'Portfolio'),
                _buildSettingItem('Version', _settings['version'] ?? '1.0.0'),
                _buildSettingItem('Description', _settings['description'] ?? 'My Portfolio App'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSettingsCard(
              'Contact Settings',
              [
                _buildSettingItem('Admin Email', 'rathin007008@gmail.com'),
                _buildSettingItem('Contact Form Enabled', _settings['contactEnabled'] ?? true),
                _buildSettingItem('Email Notifications', _settings['emailNotifications'] ?? true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildSettingsCard(
              'Security Settings',
              [
                _buildSettingItem('Admin Only Mode', _settings['adminOnly'] ?? false),
                _buildSettingItem('Registration Enabled', _settings['registrationEnabled'] ?? true),
                _buildSettingItem('Google Sign-In Enabled', _settings['googleSignInEnabled'] ?? true),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: value is bool
                ? Switch(
                    value: value,
                    onChanged: (newValue) {
                      setState(() {
                        _settings[_getSettingKey(label)] = newValue;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  )
                : Text(
                    value.toString(),
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getSettingKey(String label) {
    switch (label) {
      case 'Contact Form Enabled':
        return 'contactEnabled';
      case 'Email Notifications':
        return 'emailNotifications';
      case 'Admin Only Mode':
        return 'adminOnly';
      case 'Registration Enabled':
        return 'registrationEnabled';
      case 'Google Sign-In Enabled':
        return 'googleSignInEnabled';
      default:
        return label.toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<void> _saveSettings() async {
    final success = await AdminService.updateAppSettings(_settings);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
