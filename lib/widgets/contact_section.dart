import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingXLarge * 2,
        horizontal: Responsive.getPadding(context).horizontal,
      ),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade50
          : Colors.grey.shade900,
      child: Column(
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: AppConstants.paddingXLarge),
          Responsive.responsiveWidget(
            context: context,
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
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
                'Get In Touch',
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
                'Have a project in mind? Let\'s work together!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: AppConstants.mediumAnimation,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildContactInfo(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildContactForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return AnimationLimiter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                horizontalOffset: -50.0,
                child: FadeInAnimation(
                  child: _buildContactInfo(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingXLarge),
          Expanded(
            flex: 3,
            child: AnimationConfiguration.staggeredList(
              position: 1,
              duration: AppConstants.mediumAnimation,
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildContactForm(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Email
            _buildContactItem(
              context,
              icon: Icons.email,
              title: 'Email',
              value: AppConstants.email,
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Phone
            _buildContactItem(
              context,
              icon: Icons.phone,
              title: 'Phone',
              value: AppConstants.phone,
              onTap: () => _launchPhone(),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Location
            _buildContactItem(
              context,
              icon: Icons.location_on,
              title: 'Location',
              value: AppConstants.location,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Social Links
            Text(
              'Follow Me',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildSocialLinks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: AppConstants.iconMedium,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingMedium,
      children: AppConstants.socialLinks.map((social) {
        return IconButton(
          onPressed: () => _launchUrl(social.url),
          icon: Icon(
            AppConstants.getSocialIcon(social.platform),
            size: AppConstants.iconLarge,
          ),
          tooltip: social.platform,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            foregroundColor: Theme.of(context).primaryColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Message',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Name Field
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Email Field
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Subject Field
              FormBuilderTextField(
                name: 'subject',
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Enter message subject',
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(5),
                ]),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Message Field
              FormBuilderTextField(
                name: 'message',
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter your message',
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 5,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(10),
                ]),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: AppConstants.paddingMedium),
                            Text('Sending...'),
                          ],
                        )
                      : const Text('Send Message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isSubmitting = true);
      
      final formData = _formKey.currentState!.value;

      // Collect additional device/platform information
      final deviceInfo = await _getDeviceInfo();

      final contact = ContactModel(
        name: formData['name'],
        email: formData['email'],
        subject: formData['subject'],
        message: formData['message'],
        timestamp: DateTime.now(),
        platform: kIsWeb ? 'Web' : 'Mobile',
        userAgent: kIsWeb ? _getUserAgent() : 'Flutter Mobile App',
        ipAddress: 'Client IP', // Could be enhanced with actual IP detection
        deviceInfo: deviceInfo,
      );

      final success = await ContactService.submitContactForm(contact);
      
      setState(() => _isSubmitting = false);
      
      if (success) {
        _formKey.currentState?.reset();
        _showSnackBar('✅ Message sent! Email opened for rathin007008@gmail.com', isError: false);
      } else {
        _showSnackBar('❌ Failed to send message. Please try again.', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
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

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final mediaQuery = MediaQuery.of(context);
    return {
      'screenWidth': mediaQuery.size.width,
      'screenHeight': mediaQuery.size.height,
      'devicePixelRatio': mediaQuery.devicePixelRatio,
      'platform': kIsWeb ? 'Web Browser' : 'Mobile Device',
      'orientation': mediaQuery.orientation.toString(),
      'brightness': mediaQuery.platformBrightness.toString(),
      'textScaleFactor': mediaQuery.textScaleFactor,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _getUserAgent() {
    if (kIsWeb) {
      // In web, you could use dart:html to get actual user agent
      return 'Web Browser (Flutter Web)';
    }
    return 'Flutter Mobile App';
  }
}
