import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingLarge,
        horizontal: Responsive.getPadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade800
            : Colors.black,
      ),
      child: Column(
        children: [
          if (!Responsive.isMobile(context)) ...[
            _buildDesktopFooter(context),
          ] else ...[
            _buildMobileFooter(context),
          ],
          const SizedBox(height: AppConstants.paddingLarge),
          _buildCopyright(context),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Section
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                AppConstants.tagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                AppConstants.bio,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.paddingXLarge),
        
        // Quick Links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Links',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ...AppConstants.navItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  child: TextButton(
                    onPressed: () {
                      // Scroll to section logic would go here
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(item),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.paddingXLarge),
        
        // Contact Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildContactItem(
                context,
                icon: Icons.email,
                text: AppConstants.email,
                onTap: () => _launchEmail(),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              _buildContactItem(
                context,
                icon: Icons.phone,
                text: AppConstants.phone,
                onTap: () => _launchPhone(),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              _buildContactItem(
                context,
                icon: Icons.location_on,
                text: AppConstants.location,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildSocialLinks(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      children: [
        // Brand Section
        Column(
          children: [
            Text(
              AppConstants.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Social Links
        _buildSocialLinks(context),
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Contact Info
        Column(
          children: [
            _buildContactItem(
              context,
              icon: Icons.email,
              text: AppConstants.email,
              onTap: () => _launchEmail(),
              center: true,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildContactItem(
              context,
              icon: Icons.location_on,
              text: AppConstants.location,
              center: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool center = false,
  }) {
    final widget = Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: AppConstants.iconSmall,
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: widget,
        ),
      );
    }

    return widget;
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: AppConstants.socialLinks.map((social) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
          child: IconButton(
            onPressed: () => _launchUrl(social.url),
            icon: Icon(
              AppConstants.getSocialIcon(social.platform),
              color: Colors.white70,
              size: AppConstants.iconMedium,
            ),
            tooltip: social.platform,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          color: Colors.white24,
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'Designed & Developed with ❤️ by ${AppConstants.name}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          '© ${DateTime.now().year} ${AppConstants.name}. All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchEmail() async {
    final Uri uri = Uri(scheme: 'mailto', path: AppConstants.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri(scheme: 'tel', path: AppConstants.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
