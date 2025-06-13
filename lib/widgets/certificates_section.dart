import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/certificate_model.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class CertificatesSection extends StatelessWidget {
  const CertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final certificates = AppConstants.sampleCertificates
        .map((data) => CertificateModel.fromJson(data))
        .toList();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingXLarge * 2,
        horizontal: Responsive.getPadding(context).horizontal,
      ),
      child: Column(
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: AppConstants.paddingXLarge),
          _buildCertificatesGrid(context, certificates),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: AppConstants.mediumAnimation,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              Text(
                'Certificates & Achievements',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'My professional certifications and continuous learning journey',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificatesGrid(BuildContext context, List<CertificateModel> certificates) {
    final crossAxisCount = Responsive.getCrossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppConstants.paddingLarge,
          mainAxisSpacing: AppConstants.paddingLarge,
          childAspectRatio: Responsive.isMobile(context) ? 0.9 : 0.85,
        ),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: AppConstants.mediumAnimation,
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildCertificateCard(context, certificates[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateModel certificate) {
    return Card(
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Image/Icon
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCertificateIcon(certificate.category),
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        certificate.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                // Replace with actual certificate image:
                // Image.asset(
                //   certificate.imageUrl,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            
            // Certificate Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Certificate Title
                    Text(
                      certificate.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    
                    // Organization
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            certificate.organization,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    
                    // Completion Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          _formatDate(certificate.completionDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Description
                    Expanded(
                      child: Text(
                        certificate.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // View Certificate Button
                    if (certificate.credentialUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(certificate.credentialUrl!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View Certificate'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
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

  IconData _getCertificateIcon(String category) {
    switch (category.toLowerCase()) {
      case 'professional certification':
        return Icons.verified;
      case 'course completion':
        return Icons.school;
      case 'internship':
        return Icons.work;
      default:
        return Icons.card_membership;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
