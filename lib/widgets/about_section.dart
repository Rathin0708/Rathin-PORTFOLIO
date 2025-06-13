import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingXLarge * 2,
        horizontal: Responsive.getPadding(context).horizontal,
      ),
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
                'About Me',
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
            _buildProfileCard(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSkillsSection(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildResumeButton(context),
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
                  child: _buildProfileCard(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingXLarge),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSkillsSection(context),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildResumeButton(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Profile Image
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                  // Replace with your actual profile image:
                  // Image.asset(
                  //   'assets/images/profile.jpg',
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Name and Title
            Text(
              AppConstants.fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: AppConstants.iconSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  AppConstants.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Bio
            Text(
              AppConstants.bio,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills & Technologies',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Wrap(
          spacing: AppConstants.paddingMedium,
          runSpacing: AppConstants.paddingMedium,
          children: AppConstants.skills.map((skill) {
            return AnimationConfiguration.staggeredGrid(
              position: AppConstants.skills.indexOf(skill),
              duration: AppConstants.shortAnimation,
              columnCount: Responsive.getCrossAxisCount(
                context,
                mobile: 2,
                tablet: 3,
                desktop: 4,
              ),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: _buildSkillChip(context, skill),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(BuildContext context, String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        skill,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return SizedBox(
      width: Responsive.isMobile(context) ? double.infinity : 200,
      child: ElevatedButton.icon(
        onPressed: () => _downloadResume(),
        icon: const Icon(Icons.download),
        label: const Text('Download Resume'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
    );
  }

  Future<void> _downloadResume() async {
    final Uri url = Uri.parse(AppConstants.resumeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
