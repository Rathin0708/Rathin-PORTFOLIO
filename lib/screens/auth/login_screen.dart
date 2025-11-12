import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/admin_setup.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../portfolio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      // Reduced for smoother experience
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: kIsWeb
          ? const Duration(seconds: 60) // Much slower on web
          : const Duration(seconds: 40), // Slower for smoother web performance
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0, // Reduced slide distance
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95, // Less scale change for smoother effect
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear, // Linear for consistent web performance
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: kIsWeb ? 1.01 : 1.02, // More subtle on web
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Start background animation with a simple web check
    if (!kIsWeb) {
      _backgroundController.repeat();
    }

    _pulseController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now we can safely access MediaQuery and start background animation on large screens
    if (kIsWeb && MediaQuery
        .of(context)
        .size
        .width > 1200) {
      _backgroundController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildEnhancedBackground(),
          _buildLoginForm(),
          _buildTopDecoration(),
        ],
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              stops: [
                0.0,
                _backgroundAnimation.value * 0.3 + 0.4,
                // Reduced movement range
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Reduced floating elements for better web performance
              ...List.generate(4, (index) { // Reduced from 8 to 4
                final size = 80.0 + (index * 30);
                final opacity = 0.03 + (index * 0.02); // More subtle
                final animOffset = _backgroundAnimation.value *
                    0.5; // Slower movement
                return Positioned(
                  left: (index * 200.0) + (animOffset * 20),
                  // Simplified calculation
                  top: (index * 150.0) + (animOffset * 15),
                  child: Transform.rotate(
                    angle: _backgroundAnimation.value * 0.5 + index,
                    // Slower rotation
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.3),
                        color: Colors.white.withOpacity(opacity),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Simplified gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopDecoration() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery
                .of(context)
                .size
                .width > 800 ? 40.w : 24.w,
            vertical: 24.h,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildFormContent(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Changed breakpoint from 600 to 768
    final isDesktop = screenWidth > 1200;
    final isMobile = screenWidth <=
        768; // Changed from 600 to 768 - now mobile gets tablet styling
    final isSmallMobile = screenWidth <= 400;
    final isWebMobile = kIsWeb &&
        screenWidth <= 600; // Keep web mobile detection separate

    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop
            ? 500.w
            : isTablet
            ? 520.w // Increased tablet width from 450w to 520w - much bigger
            : isWebMobile
            ? 420.0
            : isSmallMobile
            ? screenWidth * 0.95
            : 480.w, // Mobile now gets 480w (old tablet size)
        minWidth: isWebMobile
            ? 380.0
            : isSmallMobile
            ? screenWidth * 0.9
            : 400.w, // Increased mobile minimum
      ),
      margin: EdgeInsets.symmetric(
        horizontal: isWebMobile
            ? 20.0
            : isMobile
            ? 20.w // Increased mobile margins for more spacious look
            : isTablet
            ? 50.w // Increased tablet margins
            : 20.w,
      ),
      padding: EdgeInsets.all(
        isWebMobile
            ? 32.0
            : isMobile
            ? 36.w // Increased mobile padding (old tablet size)
            : isTablet
            ? 48.w // Much bigger tablet padding
            : 32.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isWebMobile
              ? 20.0
              : isMobile
              ? 24.r // Mobile gets old tablet radius
              : isTablet
              ? 32.r // Bigger tablet radius
              : 24.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isWebMobile ? 25.0 : isMobile ? 30 : isTablet ? 40 : 25,
            // Enhanced shadows
            offset: Offset(
                0, isWebMobile ? 12.0 : isMobile ? 15 : isTablet ? 20 : 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: isWebMobile ? 10.0 : isMobile ? 12 : isTablet ? 15 : 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: _buildEnhancedLogo(),
            ),
            SizedBox(height: isWebMobile
                ? 32.0
                : isMobile
                ? 40.h // Mobile gets old tablet spacing
                : isTablet
                ? 56.h // Much bigger tablet spacing
                : 40.h),
            _buildEnhancedEmailField(),
            SizedBox(height: isWebMobile
                ? 20.0
                : isMobile
                ? 22.h // Increased mobile spacing
                : isTablet
                ? 28.h // Much bigger tablet spacing
                : 20.h),
            _buildEnhancedPasswordField(),
            SizedBox(height: isWebMobile
                ? 16.0
                : isMobile
                ? 18.h // Increased mobile spacing
                : isTablet
                ? 24.h // Bigger tablet spacing
                : 16.h),
            _buildRememberAndForgot(),
            SizedBox(height: isWebMobile
                ? 28.0
                : isMobile
                ? 32.h // Mobile gets old tablet spacing
                : isTablet
                ? 44.h // Much bigger tablet spacing
                : 32.h),
            _buildEnhancedLoginButton(),
            SizedBox(height: isWebMobile
                ? 20.0
                : isMobile
                ? 24.h // Increased mobile spacing
                : isTablet
                ? 36.h // Much bigger tablet spacing
                : 24.h),
            _buildEnhancedDivider(),
            SizedBox(height: isWebMobile
                ? 20.0
                : isMobile
                ? 24.h // Increased mobile spacing
                : isTablet
                ? 36.h // Much bigger tablet spacing
                : 24.h),
            _buildGoogleSignInButton(),
            SizedBox(height: isWebMobile
                ? 28.0
                : isMobile
                ? 32.h // Mobile gets old tablet spacing
                : isTablet
                ? 44.h // Much bigger tablet spacing
                : 32.h),
            _buildSignUpSection(),
            // if (isDesktop) ...[
            //   SizedBox(height: 24.h),
            //   _buildAdminSection(),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLogo() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint
    final isMobile = screenWidth <= 768; // Updated breakpoint
    final isSmallMobile = screenWidth <= 400;
    final isWebMobile = kIsWeb && screenWidth <= 600;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              Container(
                width: isWebMobile
                    ? 90.0
                    : isSmallMobile
                    ? 75.w
                    : isMobile
                    ? 100.w // Mobile gets bigger logo (old tablet size)
                    : isTablet
                    ? 120.w // Much bigger tablet logo
                    : 90.w,
                height: isWebMobile
                    ? 90.0
                    : isSmallMobile
                    ? 75.w
                    : isMobile
                    ? 100.w // Mobile gets bigger logo
                    : isTablet
                    ? 120.w // Much bigger tablet logo
                    : 90.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: isWebMobile
                          ? 20.0
                          : isSmallMobile
                          ? 15
                          : isMobile
                          ? 25 // Mobile gets enhanced shadow
                          : isTablet
                          ? 30 // Much bigger tablet shadow
                          : 20,
                      offset: Offset(0, isWebMobile
                          ? 8.0
                          : isSmallMobile
                          ? 5
                          : isMobile
                          ? 10 // Enhanced mobile shadow offset
                          : isTablet
                          ? 15 // Much bigger tablet shadow offset
                          : 8),
                    ),
                  ],
                ),
                child: Icon(
                  FontAwesomeIcons.user,
                  size: isWebMobile
                      ? 36.0
                      : isSmallMobile
                      ? 28.sp
                      : isMobile
                      ? 40.sp // Mobile gets bigger icon (old tablet size)
                      : isTablet
                      ? 48.sp // Much bigger tablet icon
                      : 36.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isWebMobile
                  ? 24.0
                  : isSmallMobile
                  ? 16.h
                  : isMobile
                  ? 24.h // Mobile gets old tablet spacing
                  : isTablet
                  ? 32.h // Much bigger tablet spacing
                  : 20.h),
              Text(
                'Welcome Back! ',
                style: AppTheme.headingStyle.copyWith(
                  fontSize: isWebMobile
                      ? 28.0
                      : isSmallMobile
                      ? 22.sp
                      : isMobile
                      ? 28.sp // Mobile gets old tablet font size
                      : isTablet
                      ? 36.sp // Much bigger tablet font
                      : 28.sp,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: isWebMobile
                  ? 10.0
                  : isSmallMobile
                  ? 6.h
                  : isMobile
                  ? 10.h // Mobile gets old tablet spacing
                  : isTablet
                  ? 14.h // Much bigger tablet spacing
                  : 8.h),
              Text(
                'Sign in to continue your journey',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: isWebMobile
                      ? 16.0
                      : isSmallMobile
                      ? 14.sp
                      : isMobile
                      ? 16.sp // Mobile gets old tablet font size
                      : isTablet
                      ? 20.sp // Much bigger tablet font
                      : 16.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedEmailField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;
    final isSmallMobile = screenWidth <= 400;
    final isWebMobile = kIsWeb && screenWidth <= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: isWebMobile
                ? 15.0
                : isSmallMobile
                ? 14.sp
                : isMobile
                ? 16.sp // Mobile gets bigger font (old tablet size)
                : isTablet
                ? 18.sp // Bigger tablet font
                : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isWebMobile ? 10.0 : isSmallMobile ? 8.h : isMobile
            ? 12.h
            : isTablet ? 14.h : 8.h),
        Container(
          height: isWebMobile
              ? 54.0
              : isSmallMobile
              ? 50.h
              : isMobile
              ? 58.h // Mobile gets bigger height (old tablet size)
              : isTablet
              ? 66.h // Much bigger tablet height
              : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                isWebMobile
                    ? 14.0
                    : isSmallMobile
                    ? 10.r
                    : isMobile
                    ? 16.r // Mobile gets bigger radius (old tablet size)
                    : isTablet
                    ? 20.r // Much bigger tablet radius
                    : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isWebMobile ? 14.0 : isSmallMobile ? 10 : isMobile
                    ? 18
                    : isTablet ? 25 : 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isWebMobile
                    ? 16.0
                    : isSmallMobile
                    ? 15.sp
                    : isMobile
                    ? 18.sp // Mobile gets bigger font (old tablet size)
                    : isTablet
                    ? 20.sp // Much bigger tablet font
                    : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(
                    isWebMobile
                        ? 12.0
                        : isSmallMobile
                        ? 8.w
                        : isMobile
                        ? 14.w // Mobile gets bigger margins (old tablet size)
                        : isTablet
                        ? 16.w // Much bigger tablet margins
                        : 12.w),
                padding: EdgeInsets.all(isWebMobile
                    ? 8.0
                    : isSmallMobile
                    ? 6.w
                    : isMobile
                    ? 10.w // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 12.w // Much bigger tablet padding
                    : 8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      isWebMobile
                          ? 8.0
                          : isSmallMobile
                          ? 6.r
                          : isMobile
                          ? 10.r // Mobile gets bigger radius (old tablet size)
                          : isTablet
                          ? 12.r // Much bigger tablet radius
                          : 8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.envelope,
                  size: isWebMobile
                      ? 16.0
                      : isSmallMobile
                      ? 14.sp
                      : isMobile
                      ? 18.sp // Mobile gets bigger icon (old tablet size)
                      : isTablet
                      ? 20.sp // Much bigger tablet icon
                      : 16.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r // Mobile gets bigger radius (old tablet size)
                        : isTablet
                        ? 20.r // Much bigger tablet radius
                        : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r
                        : isTablet
                        ? 20.r
                        : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r
                        : isTablet
                        ? 20.r
                        : 14.r),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isWebMobile
                    ? 18.0
                    : isSmallMobile
                    ? 14.w
                    : isMobile
                    ? 22.w // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 28.w // Much bigger tablet padding
                    : 20.w,
                vertical: isWebMobile
                    ? 16.0
                    : isSmallMobile
                    ? 12.h
                    : isMobile
                    ? 18.h // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 22.h // Much bigger tablet padding
                    : 16.h,
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email is required'),
              FormBuilderValidators.email(errorText: 'Enter a valid email'),
            ]),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: isWebMobile
                  ? 16.0
                  : isSmallMobile
                  ? 15.sp
                  : isMobile
                  ? 18.sp // Mobile gets bigger font (old tablet size)
                  : isTablet
                  ? 20.sp // Much bigger tablet font
                  : 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedPasswordField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;
    final isSmallMobile = screenWidth <= 400;
    final isWebMobile = kIsWeb && screenWidth <= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: isWebMobile
                ? 15.0
                : isSmallMobile
                ? 14.sp
                : isMobile
                ? 16.sp // Mobile gets bigger font (old tablet size)
                : isTablet
                ? 18.sp // Bigger tablet font
                : 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isWebMobile ? 10.0 : isSmallMobile ? 8.h : isMobile
            ? 12.h
            : isTablet ? 14.h : 8.h),
        Container(
          height: isWebMobile
              ? 54.0
              : isSmallMobile
              ? 50.h
              : isMobile
              ? 58.h // Mobile gets bigger height (old tablet size)
              : isTablet
              ? 66.h // Much bigger tablet height
              : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                isWebMobile
                    ? 14.0
                    : isSmallMobile
                    ? 10.r
                    : isMobile
                    ? 16.r // Mobile gets bigger radius (old tablet size)
                    : isTablet
                    ? 20.r // Much bigger tablet radius
                    : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isWebMobile ? 14.0 : isSmallMobile ? 10 : isMobile
                    ? 18
                    : isTablet ? 25 : 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isWebMobile
                    ? 16.0
                    : isSmallMobile
                    ? 15.sp
                    : isMobile
                    ? 18.sp // Mobile gets bigger font (old tablet size)
                    : isTablet
                    ? 20.sp // Much bigger tablet font
                    : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(
                    isWebMobile
                        ? 12.0
                        : isSmallMobile
                        ? 8.w
                        : isMobile
                        ? 14.w // Mobile gets bigger margins (old tablet size)
                        : isTablet
                        ? 16.w // Much bigger tablet margins
                        : 12.w),
                padding: EdgeInsets.all(isWebMobile
                    ? 8.0
                    : isSmallMobile
                    ? 6.w
                    : isMobile
                    ? 10.w // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 12.w // Much bigger tablet padding
                    : 8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      isWebMobile
                          ? 8.0
                          : isSmallMobile
                          ? 6.r
                          : isMobile
                          ? 10.r // Mobile gets bigger radius (old tablet size)
                          : isTablet
                          ? 12.r // Much bigger tablet radius
                          : 8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.lock,
                  size: isWebMobile
                      ? 16.0
                      : isSmallMobile
                      ? 14.sp
                      : isMobile
                      ? 18.sp // Mobile gets bigger icon (old tablet size)
                      : isTablet
                      ? 20.sp // Much bigger tablet icon
                      : 16.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r // Mobile gets bigger radius (old tablet size)
                        : isTablet
                        ? 20.r // Much bigger tablet radius
                        : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r
                        : isTablet
                        ? 20.r
                        : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isWebMobile
                        ? 14.0
                        : isSmallMobile
                        ? 10.r
                        : isMobile
                        ? 16.r
                        : isTablet
                        ? 20.r
                        : 14.r),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isWebMobile
                    ? 18.0
                    : isSmallMobile
                    ? 14.w
                    : isMobile
                    ? 22.w // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 28.w // Much bigger tablet padding
                    : 20.w,
                vertical: isWebMobile
                    ? 16.0
                    : isSmallMobile
                    ? 12.h
                    : isMobile
                    ? 18.h // Mobile gets bigger padding (old tablet size)
                    : isTablet
                    ? 22.h // Much bigger tablet padding
                    : 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                  size: isWebMobile
                      ? 22.0
                      : isSmallMobile
                      ? 18
                      : isMobile
                      ? 24 // Mobile gets bigger icon (old tablet size)
                      : isTablet
                      ? 28 // Much bigger tablet icon
                      : 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Password is required'),
              FormBuilderValidators.minLength(
                  6, errorText: 'Password must be at least 6 characters'),
            ]),
            style: TextStyle(
              fontSize: isWebMobile
                  ? 16.0
                  : isSmallMobile
                  ? 15.sp
                  : isMobile
                  ? 18.sp // Mobile gets bigger font (old tablet size)
                  : isTablet
                  ? 20.sp // Much bigger tablet font
                  : 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth <= 360; // Very small phones
    final isMobile = screenWidth <= 768; // Mobile view

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.w : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: isSmallScreen ? 2 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: isSmallScreen ? 0.7 : 0.8,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14.sp : isMobile ? 16.sp : 14
                          .sp, // Increased mobile font size
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: isSmallScreen ? 3 : 1,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    const ForgotPasswordScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation,
                        child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                              begin: const Offset(1.0, 0.0), end: Offset.zero),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.w : 16.w,
                  vertical: 8.h,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: isSmallScreen ? 14.sp : isMobile ? 16.sp : 14.sp,
                  // Increased mobile font size
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLoginButton() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          width: double.infinity,
          height: isMobile ? 52.h : isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                isMobile ? 12.r : isTablet ? 16.r : 14.r),
            gradient: LinearGradient(
              colors: [
                Theme
                    .of(context)
                    .primaryColor,
                Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(0.3),
                blurRadius: isMobile ? 15 : isTablet ? 20 : 15,
                offset: Offset(0, isMobile ? 6 : 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 14.h : isTablet ? 16.h : 12.h,
                horizontal: isMobile ? 24.w : isTablet ? 32.w : 24.w,
              ),
            ),
            child: authProvider.isLoading
                ? SizedBox(
              height: isMobile ? 22 : isTablet ? 28 : 24,
              width: isMobile ? 22 : isTablet ? 28 : 24,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Sign In',
              style: TextStyle(
                fontSize: isMobile ? 17.sp : isTablet ? 20.sp : 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          width: double.infinity,
          height: isMobile ? 52.h : isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                isMobile ? 12.r : isTablet ? 16.r : 14.r),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isMobile ? 12 : isTablet ? 20 : 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 14.h : isTablet ? 16.h : 12.h,
                horizontal: isMobile ? 20.w : isTablet ? 32.w : 24.w,
              ),
            ),
            icon: authProvider.isLoading
                ? SizedBox(
              height: isMobile ? 18 : isTablet ? 24 : 20,
              width: isMobile ? 18 : isTablet ? 24 : 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                strokeWidth: 2,
              ),
            )
                : Icon(
              FontAwesomeIcons.google,
              size: isMobile ? 16 : isTablet ? 22 : 18,
              color: const Color(0xFFDB4437),
            ),
            label: Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: isMobile ? 15.sp : isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'OR',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpSection() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isMobile = screenWidth <= 768; // Mobile view

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isMobile ? 26.sp : 15.sp, // Increased mobile font size
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const RegisterScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: isMobile ? 27.sp : 15.sp, // Increased mobile font size
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection() {
    return ExpansionTile(
      title: Text(
        'Admin Access',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
      children: [
        SizedBox(height: 12.h),
        _buildAdminSetupButton(),
        SizedBox(height: 12.h),
        _buildDirectAdminLoginButton(),
      ],
    );
  }

  Widget _buildAdminSetupButton() {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleAdminSetup,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.userGear,
                  size: 16.sp,
                  color: Colors.orange[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  'Setup Admin Account',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectAdminLoginButton() {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleDirectAdminLogin,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.rightToBracket,
                  size: 16.sp,
                  color: Colors.green[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  'Direct Admin Login',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDirectAdminLogin() async {
    try {
      // Pre-fill the form with admin credentials
      _formKey.currentState?.patchValue({
        'email': AdminSetup.adminEmail,
        'password': AdminSetup.adminPassword,
      });

      // Show loading
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Attempt direct login
      final success = await authProvider.signInWithEmailPassword(
        email: AdminSetup.adminEmail,
        password: AdminSetup.adminPassword,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (success) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PortfolioScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // If login fails, show password reset option
        if (mounted) {
          _showPasswordResetDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showPasswordResetDialog();
      }
    }
  }

  void _showPasswordResetDialog() {
    if (!mounted) return; // Safety check

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.orange,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            const Text('Login Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin login failed. This might be because:'),
            SizedBox(height: 8.h),
            Text('• Password needs to be reset',
                style: TextStyle(fontSize: 14.sp)),
            Text('• Account needs verification',
                style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 16.h),
            const Text('Would you like to reset the password?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdminSetup() async {
    try {
      if (!mounted) return; // Check before showing dialog

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(width: 16.w),
                  const Text('Setting up admin account...'),
                ],
              ),
            ),
      );

      // Create admin account
      final success = await AdminSetup.createAdminAccount();

      if (!mounted) return; // Check before closing dialog

      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Pre-fill the form with admin credentials
        _formKey.currentState?.patchValue({
          'email': AdminSetup.adminEmail,
          'password': AdminSetup.adminPassword,
        });

        // Show options dialog
        if (mounted) {
          _showAdminSetupSuccessDialog();
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
              'Failed to setup admin account. Please try again.');
        }
      }
    } catch (e) {
      // Close loading dialog if still open and widget is mounted
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showAdminSetupSuccessDialog() {
    if (!mounted) return; // Safety check

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.circleCheck,
              color: Colors.green,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            const Text('Admin Account Ready'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your admin account is ready!'),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${AdminSetup.adminEmail}',
                      style: TextStyle(fontSize: 14.sp)),
                  Text('Password: ${AdminSetup.adminPassword}',
                      style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
                'The login form has been pre-filled. Tap "Sign In" to access the admin panel.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Send password reset email as backup
              _sendPasswordResetEmail();
            },
            child: const Text('Reset Password'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Auto-login
              _handleLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      await AdminSetup.resetAdminPassword();

      if (!mounted) return; // Check before showing SnackBar

      _showSuccessSnackBar(
          'Password reset email sent to ${AdminSetup.adminEmail}');
    } catch (e) {
      if (!mounted) return; // Check before showing SnackBar

      _showErrorSnackBar('Failed to send reset email: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signInWithEmailPassword(
        email: formData['email'],
        password: formData['password'],
      );

      if (!mounted) return; // Check if widget is still mounted

      if (success) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PortfolioScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Login failed');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PortfolioScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Google sign-in failed');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              FontAwesomeIcons.circleCheck,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
