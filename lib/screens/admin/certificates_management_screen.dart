import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/admin_service.dart';
import '../../models/certificate_model.dart';
import '../../utils/app_theme.dart';

class CertificatesManagementScreen extends StatefulWidget {
  const CertificatesManagementScreen({super.key});

  @override
  State<CertificatesManagementScreen> createState() => _CertificatesManagementScreenState();
}

class _CertificatesManagementScreenState extends State<CertificatesManagementScreen> {
  List<CertificateModel> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      final certificates = await AdminService.getCertificates();
      setState(() {
        _certificates = certificates;
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
        title: const Text('Certificates Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddCertificateDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Certificate',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? _buildEmptyState()
              : _buildCertificatesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.card_membership_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'No Certificates Added Yet',
              style: AppTheme.headingStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _showAddCertificateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Certificate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList() {
    return RefreshIndicator(
      onRefresh: _loadCertificates,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _certificates.length,
        itemBuilder: (context, index) {
          final certificate = _certificates[index];
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildCertificateCard(certificate),
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel certificate) {
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
                  child: const Icon(
                    Icons.card_membership,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.title,
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        certificate.organization,
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
                      _showEditCertificateDialog(certificate);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(certificate);
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
            if (certificate.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                certificate.description,
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Completed: ${_formatDate(certificate.completionDate)}',
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (certificate.expiryDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: certificate.isExpired ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${_formatDate(certificate.expiryDate!)}',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 12,
                      color: certificate.isExpired ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            if (certificate.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: certificate.skills.map((skill) {
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
                      skill,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 10,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddCertificateDialog() {
    // TODO: Implement add certificate dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add certificate dialog - Coming soon!'),
      ),
    );
  }

  void _showEditCertificateDialog(CertificateModel certificate) {
    // TODO: Implement edit certificate dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit certificate dialog - Coming soon!'),
      ),
    );
  }

  void _showDeleteConfirmation(CertificateModel certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text('Are you sure you want to delete "${certificate.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCertificate(certificate),
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

  Future<void> _deleteCertificate(CertificateModel certificate) async {
    final success = await AdminService.deleteCertificate(certificate.id!);
    
    if (success) {
      Navigator.pop(context);
      _loadCertificates();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete certificate'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
