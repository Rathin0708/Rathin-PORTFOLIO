import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
        child: Responsive.responsiveWidget(
          context: context,
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
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
                _buildProfileImage(context),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildGreeting(context),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildAnimatedTagline(context),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildDescription(context),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
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
                  _buildGreeting(context),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildAnimatedTagline(context),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildDescription(context),
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
                child: _buildProfileImage(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
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
          child: const Icon(
            Icons.person,
            size: 150,
            color: Colors.white,
          ),
          // Replace with your actual profile image:
          // Image.asset(
          //   'assets/images/profile.jpg',
          //   fit: BoxFit.cover,
          // ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Text(
      "Hey, I'm ${AppConstants.name} 👋",
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

  Widget _buildAnimatedTagline(BuildContext context) {
    return SizedBox(
      height: 60,
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Flutter Developer',
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
          TypewriterAnimatedText(
            'Firebase Expert',
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
          TypewriterAnimatedText(
            'UI/UX Enthusiast',
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

  Widget _buildDescription(BuildContext context) {
    return Text(
      AppConstants.bio,
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

  void _scrollToSection(int index) {
    scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: AppConstants.mediumAnimation,
    );
  }
}
