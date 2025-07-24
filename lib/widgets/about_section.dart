import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('portfolio_settings')
                .doc('profile')
                .snapshots(),
            builder: (context, profileSnapshot) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('portfolio_settings')
                    .doc('about')
                    .snapshots(),
                builder: (context, aboutSnapshot) {
                  // Get profile data or use defaults
                  final profileData = profileSnapshot.hasData &&
                      profileSnapshot.data!.exists
                      ? profileSnapshot.data!.data() as Map<String, dynamic>?
                      : null;

                  // Get about data or use defaults  
                  final aboutData = aboutSnapshot.hasData &&
                      aboutSnapshot.data!.exists
                      ? aboutSnapshot.data!.data() as Map<String, dynamic>?
                      : null;

                  final name = profileData?['name'] ?? AppConstants.fullName;
                  final tagline = profileData?['tagline'] ??
                      AppConstants.tagline;
                  final location = profileData?['location'] ??
                      AppConstants.location;
                  final profileImage = profileData?['profileImage'] ?? '';
                  final resumeUrl = profileData?['resumeUrl'] ??
                      AppConstants.resumeUrl;
                  final bio = aboutData?['bio'] ?? AppConstants.bio;
                  final skills = aboutData?['skills'] != null
                      ? List<String>.from(aboutData!['skills'])
                      : AppConstants.skills;

                  return Responsive.responsiveWidget(
                    context: context,
                    mobile: _buildMobileLayout(
                        context,
                        name,
                        tagline,
                        location,
                        profileImage,
                        bio,
                        skills,
                        resumeUrl),
                    desktop: _buildDesktopLayout(
                        context,
                        name,
                        tagline,
                        location,
                        profileImage,
                        bio,
                        skills,
                        resumeUrl),
                  );
                },
              );
            },
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

  Widget _buildMobileLayout(BuildContext context, String name, String tagline,
      String location, String profileImage, String bio, List<String> skills,
      String resumeUrl) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: AppConstants.mediumAnimation,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildProfileCard(
                context, name, tagline, location, profileImage, bio),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSkillsSection(context, skills),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildResumeButton(context, resumeUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String name, String tagline,
      String location, String profileImage, String bio, List<String> skills,
      String resumeUrl) {
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
                  child: _buildProfileCard(
                      context, name, tagline, location, profileImage, bio),
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
                      child: _buildSkillsSection(context, skills),
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
                      child: _buildResumeButton(context, resumeUrl),
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

  Widget _buildProfileCard(BuildContext context, String name, String tagline,
      String location, String profileImage, String bio) {
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
                child: profileImage.isEmpty
                    ? Container(
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
                )
                    : profileImage.startsWith('assets/')
                    ? Image.asset(
                  profileImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                        '❌ Error loading asset profile image in about section: $error');
                    return Container(
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
                    );
                  },
                )
                    : CachedNetworkImage(
                  imageUrl: profileImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) {
                    print(
                        '❌ Error loading profile image in about section: $error');
                    return Container(
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
                    );
                  },
                          ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Name and Title
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              tagline,
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
                  location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Bio
            Text(
              bio,
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

  Widget _buildSkillsSection(BuildContext context, List<String> skills) {
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
          children: skills.map((skill) {
            return AnimationConfiguration.staggeredGrid(
              position: skills.indexOf(skill),
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

  Widget _buildResumeButton(BuildContext context, String resumeUrl) {
    return SizedBox(
      width: Responsive.isMobile(context) ? double.infinity : 200,
      child: ElevatedButton.icon(
        onPressed: () => _downloadResume(resumeUrl),
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

  Future<void> _downloadResume(String resumeUrl) async {
    final Uri url = Uri.parse(resumeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
