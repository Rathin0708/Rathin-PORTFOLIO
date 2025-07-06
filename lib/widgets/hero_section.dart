import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';

class HeroSection extends StatelessWidget {
  final AutoScrollController scrollController;

  const HeroSection({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Padding(
        padding: Responsive.getPadding(context),
        child: StreamBuilder<DocumentSnapshot>(
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

                final name = profileData?['name'] ?? AppConstants.name;
                final tagline = profileData?['tagline'] ?? AppConstants.tagline;
                final bio = aboutData?['bio'] ?? AppConstants.bio;
                final profileImage = profileData?['profileImage'] ?? '';

                return Responsive.responsiveWidget(
                  context: context,
                  mobile: _buildMobileLayout(
                      context, name, tagline, bio, profileImage),
                  desktop: _buildDesktopLayout(
                      context, name, tagline, bio, profileImage),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, String name, String tagline,
      String bio, String profileImage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: AppConstants.longAnimation,
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildProfileImage(context, profileImage),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildGreeting(context, name),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildAnimatedTagline(context, tagline),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildDescription(context, bio),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String name, String tagline,
      String bio, String profileImage) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: AppConstants.longAnimation,
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: -50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildGreeting(context, name),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildAnimatedTagline(context, tagline),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildDescription(context, bio),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingXLarge),
        Expanded(
          flex: 2,
          child: AnimationConfiguration.staggeredList(
            position: 1,
            duration: AppConstants.longAnimation,
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProfileImage(context, profileImage),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context, String profileImage) {
    final size = Responsive.isMobile(context) ? 200.0 : 300.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
          child: ClipOval(
            child: _buildActualProfileImage(profileImage),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String name) {
    return Text(
      "Hey, I'm $name 👋",
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        color: Colors.white,
        fontSize: Responsive.getFontSize(
          context,
          mobile: 32,
          tablet: 40,
          desktop: 48,
        ),
      ),
      textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
    );
  }

  Widget _buildAnimatedTagline(BuildContext context, String tagline) {
    return SizedBox(
      height: 60,
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            tagline,
            textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontSize: Responsive.getFontSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
        repeatForever: true,
        pause: const Duration(milliseconds: 1000),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String bio) {
    return Text(
      bio,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white.withOpacity(0.9),
        fontSize: Responsive.getFontSize(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 18,
        ),
        height: 1.6,
      ),
      textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Responsive.responsiveWidget(
      context: context,
      mobile: Column(
        children: [
          _buildPrimaryButton(context),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildSecondaryButton(context),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: Responsive.isMobile(context) 
            ? MainAxisAlignment.center 
            : MainAxisAlignment.start,
        children: [
          _buildPrimaryButton(context),
          const SizedBox(width: AppConstants.paddingMedium),
          _buildSecondaryButton(context),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _scrollToSection(2), // Projects section
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.darkBackgroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      child: const Text(
        'View My Work',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _scrollToSection(4), // Contact section
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      child: const Text(
        'Get In Touch',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActualProfileImage(String profileImage) {
    if (profileImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackProfileImage(),
      );
    } else {
      return _buildFallbackProfileImage();
    }
  }

  Widget _buildFallbackProfileImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          AppConstants.name.isNotEmpty
              ? AppConstants.name.substring(0, 1).toUpperCase()
              : 'R',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: AppConstants.mediumAnimation,
    );
  }
}
