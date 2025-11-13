import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';

class HeroSection extends StatefulWidget {
  final AutoScrollController scrollController;

  const HeroSection({
    super.key,
    required this.scrollController,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Pulse animation for buttons
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _backgroundController.repeat();
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          // Floating geometric shapes
          _buildFloatingShapes(),
          // Main content
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                  _backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFFf093fb),
                  const Color(0xFF667eea),
                  _backgroundAnimation.value,
                )!,
              ],
              stops: [
                0.0,
                0.5 + (_backgroundAnimation.value * 0.3),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Large floating circle
            Positioned(
              top: 100 + (_floatingAnimation.value * 30),
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Medium floating square
            Positioned(
              top: 300 + (_floatingAnimation.value * -20),
              left: -30,
              child: Transform.rotate(
                angle: _floatingAnimation.value * 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Small floating triangle
            Positioned(
              bottom: 200 + (_floatingAnimation.value * 25),
              right: 50,
              child: Transform.rotate(
                angle: _floatingAnimation.value * -0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Scattered particles
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 80.0) + (_floatingAnimation.value * 20),
                top: (index * 60.0) + (_floatingAnimation.value * 15),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
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

              // Fix invalid profile image references directly
              String profileImage = profileData?['profileImage'] ?? '';
              if (profileImage.contains('profile1.jpg') ||
                  profileImage.contains('profile2.jpg') ||
                  profileImage.contains('profile3.jpg') ||
                  profileImage.contains('profile4.jpg')) {
                // Replace with valid existing asset
                profileImage = 'assets/images/profile.jpg';
                print(
                    '🔧 Fixed invalid profile image reference in hero section');
              }

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
                verticalOffset: 80.0,
                child: FadeInAnimation(
                  duration: const Duration(milliseconds: 1000),
                  child: widget,
                ),
              ),
              children: [
                _buildEnhancedProfileImage(context, profileImage),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildEnhancedGreeting(context, name),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildEnhancedAnimatedTagline(context, tagline),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildEnhancedDescription(context, bio),
                const SizedBox(height: AppConstants.paddingXLarge),
                _buildEnhancedActionButtons(context),
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
                  horizontalOffset: -100.0,
                  child: FadeInAnimation(
                    duration: const Duration(milliseconds: 1200),
                    child: widget,
                  ),
                ),
                children: [
                  _buildEnhancedGreeting(context, name),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildEnhancedAnimatedTagline(context, tagline),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildEnhancedDescription(context, bio),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  _buildEnhancedActionButtons(context),
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
              horizontalOffset: 100.0,
              child: FadeInAnimation(
                duration: const Duration(milliseconds: 1200),
                child: _buildEnhancedProfileImage(context, profileImage),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProfileImage(BuildContext context, String profileImage) {
    final size = Responsive.isMobile(context) ? 220.0 : 320.0;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: Offset(0, 15 + (_floatingAnimation.value * 5)),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Outer glowing ring
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
                // Inner image container
                Positioned(
                  top: 8,
                  left: 8,
                  child: ClipOval(
                    child: Container(
                      width: size - 16,
                      height: size - 16,
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
                      child: ClipOval(
                        child: _buildActualProfileImage(profileImage),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedGreeting(BuildContext context, String name) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
      child: Text(
        "Hey, I'm $name 👋",
        style: Theme
            .of(context)
            .textTheme
            .displayLarge
            ?.copyWith(
          color: Colors.white,
          fontSize: Responsive.getFontSize(
            context,
            mobile: 36,
            tablet: 44,
            desktop: 52,
          ),
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign
            .left,
      ),
    );
  }

  Widget _buildEnhancedAnimatedTagline(BuildContext context, String tagline) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              tagline,
              textStyle: Theme
                  .of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(
                color: AppTheme.secondaryColor,
                fontSize: Responsive.getFontSize(
                  context,
                  mobile: 22,
                  tablet: 26,
                  desktop: 30,
                ),
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ) ?? const TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
              speed: const Duration(milliseconds: 80),
            ),
            ColorizeAnimatedText(
              tagline,
              textStyle: Theme
                  .of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(
                fontSize: Responsive.getFontSize(
                  context,
                  mobile: 22,
                  tablet: 26,
                  desktop: 30,
                ),
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              colors: [
                AppTheme.secondaryColor,
                Colors.white,
                const Color(0xFFf093fb),
                AppTheme.secondaryColor,
              ],
              speed: const Duration(milliseconds: 200),
            ),
          ],
          repeatForever: true,
          pause: const Duration(milliseconds: 1500),
        ),
      ),
    );
  }

  Widget _buildEnhancedDescription(BuildContext context, String bio) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        bio,
        style: Theme
            .of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(
          color: Colors.white.withOpacity(0.95),
          fontSize: Responsive.getFontSize(
            context,
            mobile: 17,
            tablet: 19,
            desktop: 19,
          ),
          height: 1.7,
          fontWeight: FontWeight.w400,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign
            .left,
      ),
    );
  }

  Widget _buildEnhancedActionButtons(BuildContext context) {
    return Responsive.responsiveWidget(
      context: context,
      mobile: Column(
        children: [
          _buildEnhancedPrimaryButton(context),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildEnhancedSecondaryButton(context),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: Responsive.isMobile(context) 
            ? MainAxisAlignment.center 
            : MainAxisAlignment.start,
        children: [
          _buildEnhancedPrimaryButton(context),
          const SizedBox(width: AppConstants.paddingMedium),
          _buildEnhancedSecondaryButton(context),
        ],
      ),
    );
  }

  Widget _buildEnhancedPrimaryButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor,
                  AppTheme.secondaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _scrollToSection(2), // Projects section
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.darkBackgroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.work_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'View My Work',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSecondaryButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: () => _scrollToSection(4), // Contact section
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide.none,
          backgroundColor: Colors.white.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contact_mail_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Get In Touch',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActualProfileImage(String profileImage) {
    // Check if it's a local asset
    if (profileImage.startsWith('assets/')) {
      return Image.asset(
        profileImage,
        width: 350,
        height: 350,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print(' Error loading asset profile image: $error');
          return _buildFallbackProfileImage();
        },
      );
    }

    // Handle network images (Firebase URLs)
    if (profileImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImage,
        width: 350,
        height: 350,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(
              width: 350,
              height: 350,
              color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print(' Error loading profile image: $error');
          return _buildFallbackProfileImage();
        },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.name.isNotEmpty
                  ? AppConstants.name.substring(0, 1).toUpperCase()
                  : 'R',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    widget.scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: AppConstants.mediumAnimation,
    );
  }
}
