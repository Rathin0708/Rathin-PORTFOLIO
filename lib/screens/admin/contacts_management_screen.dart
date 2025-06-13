import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';

class ContactsManagementScreen extends StatefulWidget {
  const ContactsManagementScreen({super.key});

  @override
  State<ContactsManagementScreen> createState() => _ContactsManagementScreenState();
}

class _ContactsManagementScreenState extends State<ContactsManagementScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await AdminService.getContactMessages();
      setState(() {
        _contacts = contacts;
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
        title: const Text('Contact Messages'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.contact_mail_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'No Messages Yet',
              style: AppTheme.headingStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildContactCard(contact),
          );
        },
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            contact['name']?[0]?.toUpperCase() ?? 'U',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact['name'] ?? 'Unknown',
          style: AppTheme.headingStyle.copyWith(fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact['subject'] ?? 'No Subject',
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact['email'] ?? '',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatTimestamp(contact['timestamp']),
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message:',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    contact['message'] ?? 'No message',
                    style: AppTheme.bodyStyle,
                  ),
                ),
                if (contact['deviceInfo'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Device Info:',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      _formatDeviceInfo(contact['deviceInfo']),
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _replyToContact(contact),
                        icon: const Icon(Icons.reply),
                        label: const Text('Reply'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsRead(contact),
                        icon: const Icon(Icons.mark_email_read),
                        label: const Text('Mark Read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDeviceInfo(dynamic deviceInfo) {
    if (deviceInfo == null) return 'No device info';
    
    try {
      if (deviceInfo is Map) {
        final buffer = StringBuffer();
        deviceInfo.forEach((key, value) {
          buffer.writeln('$key: $value');
        });
        return buffer.toString();
      }
      return deviceInfo.toString();
    } catch (e) {
      return 'Error parsing device info';
    }
  }

  void _replyToContact(Map<String, dynamic> contact) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reply to ${contact['email']} - Coming soon!'),
      ),
    );
  }

  void _markAsRead(Map<String, dynamic> contact) {
    // TODO: Implement mark as read functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
