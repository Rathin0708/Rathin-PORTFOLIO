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
import 'login_screen.dart';
import '../portfolio_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
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
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _passwordStrength = 'Weak';
  double _passwordStrengthValue = 0.0;
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Web-optimized durations
    final mainDuration = kIsWeb
        ? const Duration(milliseconds: 1200)
        : const Duration(milliseconds: 800);
    final backgroundDuration = kIsWeb
        ? const Duration(seconds: 60)
        : const Duration(seconds: 35);

    _animationController = AnimationController(
      duration: mainDuration,
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: backgroundDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 5),
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
          _buildRegisterForm(),
          _buildTopDecoration(),
        ],
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final movementRange = kIsWeb ? 0.2 : 0.4;
        final elementCount = kIsWeb ? 3 : 5;
        final animSpeed = kIsWeb ? 0.3 : 0.5;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF764ba2),
                const Color(0xFF667eea),
                AppTheme.accentColor.withOpacity(0.8),
              ],
              stops: [
                0.0,
                _backgroundAnimation.value * movementRange + 0.4,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Reduced floating elements for better web performance
              ...List.generate(elementCount, (index) {
                final size = 70.0 + (index * 25);
                final opacity = 0.03 + (index * 0.015); // More subtle
                final isCircle = index % 2 == 0;
                final animOffset = _backgroundAnimation.value * animSpeed;
                return Positioned(
                  right: (index * 180.0) + (animOffset * 25),
                  top: (index * 120.0) + (animOffset * 20),
                  child: Transform.rotate(
                    angle: _backgroundAnimation.value * animSpeed + index,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: isCircle
                            ? BorderRadius.circular(size / 2)
                            : BorderRadius.circular(size * 0.2),
                        color: Colors.white.withOpacity(opacity),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            blurRadius: 6,
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
                      Colors.black.withOpacity(0.03),
                      Colors.black.withOpacity(0.15),
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

  Widget _buildRegisterForm() {
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
            ? 520.w
            : isTablet
            ? 540.w // Increased tablet width from 480w to 540w - much bigger
            : isWebMobile
            ? 450.0
            : isSmallMobile
            ? screenWidth * 0.95
            : 500.w, // Mobile now gets 500w (old tablet size)
        minWidth: isWebMobile
            ? 420.0
            : isSmallMobile
            ? screenWidth * 0.9
            : 420.w, // Increased mobile minimum
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
              duration: Duration(milliseconds: kIsWeb ? 600 : 400),
              child: _buildEnhancedLogo(),
            ),
            SizedBox(height: isWebMobile ? 32.0 : isMobile ? 44.h : isTablet
                ? 56.h
                : 40.h), // Increased spacing
            _buildNameField(),
            SizedBox(height: isWebMobile ? 18.0 : isMobile ? 22.h : isTablet
                ? 28.h
                : 20.h),
            // Increased spacing
            _buildEmailField(),
            SizedBox(height: isWebMobile ? 18.0 : isMobile ? 22.h : isTablet
                ? 28.h
                : 20.h),
            // Increased spacing
            _buildPasswordField(),
            SizedBox(height: isWebMobile ? 14.0 : isMobile ? 18.h : isTablet
                ? 24.h
                : 16.h),
            // Increased spacing
            _buildConfirmPasswordField(),
            SizedBox(height: isWebMobile ? 18.0 : isMobile ? 22.h : isTablet
                ? 28.h
                : 20.h),
            // Increased spacing
            _buildTermsCheckbox(),
            SizedBox(height: isWebMobile ? 28.0 : isMobile ? 36.h : isTablet
                ? 48.h
                : 32.h),
            // Increased spacing
            _buildEnhancedRegisterButton(),
            SizedBox(height: isWebMobile ? 20.0 : isMobile ? 26.h : isTablet
                ? 36.h
                : 24.h),
            // Increased spacing
            _buildEnhancedDivider(),
            SizedBox(height: isWebMobile ? 20.0 : isMobile ? 26.h : isTablet
                ? 36.h
                : 24.h),
            // Increased spacing
            _buildEnhancedGoogleButton(),
            SizedBox(height: isWebMobile ? 28.0 : isMobile ? 36.h : isTablet
                ? 48.h
                : 32.h),
            // Increased spacing
            _buildSignInSection(),
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
                    ? 105.w // Mobile gets bigger logo (old tablet size)
                    : isTablet
                    ? 125.w // Much bigger tablet logo
                    : 90.w,
                height: isWebMobile
                    ? 90.0
                    : isSmallMobile
                    ? 75.w
                    : isMobile
                    ? 105.w // Mobile gets bigger logo
                    : isTablet
                    ? 125.w // Much bigger tablet logo
                    : 90.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF764ba2),
                      Color(0xFF667eea),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: isWebMobile
                          ? 20.0
                          : isSmallMobile
                          ? 15
                          : isMobile
                          ? 28 // Mobile gets enhanced shadow
                          : isTablet
                          ? 35 // Much bigger tablet shadow
                          : 20,
                      offset: Offset(0, isWebMobile
                          ? 8.0
                          : isSmallMobile
                          ? 5
                          : isMobile
                          ? 12 // Enhanced mobile shadow offset
                          : isTablet
                          ? 16 // Much bigger tablet shadow offset
                          : 8),
                    ),
                  ],
                ),
                child: Icon(
                  FontAwesomeIcons.userPlus,
                  size: isWebMobile
                      ? 36.0
                      : isSmallMobile
                      ? 28.sp
                      : isMobile
                      ? 42.sp // Mobile gets bigger icon (old tablet size)
                      : isTablet
                      ? 52.sp // Much bigger tablet icon
                      : 36.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isWebMobile
                  ? 24.0
                  : isSmallMobile
                  ? 16.h
                  : isMobile
                  ? 26.h // Mobile gets bigger spacing (old tablet size)
                  : isTablet
                  ? 34.h // Much bigger tablet spacing
                  : 20.h),
              Text(
                'Create Account ✨',
                style: AppTheme.headingStyle.copyWith(
                  fontSize: isWebMobile
                      ? 28.0
                      : isSmallMobile
                      ? 22.sp
                      : isMobile
                      ? 30.sp // Mobile gets bigger font (old tablet size)
                      : isTablet
                      ? 38.sp // Much bigger tablet font
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
                  ? 12.h // Mobile gets bigger spacing (old tablet size)
                  : isTablet
                  ? 16.h // Much bigger tablet spacing
                  : 8.h),
              Text(
                'Join our community today',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: isWebMobile
                      ? 16.0
                      : isSmallMobile
                      ? 14.sp
                      : isMobile
                      ? 17.sp // Mobile gets bigger font (old tablet size)
                      : isTablet
                      ? 21.sp // Much bigger tablet font
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

  Widget _buildNameField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint
    final isMobile = screenWidth <= 768; // Updated breakpoint

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: isMobile ? 15.sp : isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isMobile ? 10.h : 8.h),
        Container(
          height: isMobile ? 52.h : isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                isMobile ? 12.r : isTablet ? 16.r : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isMobile ? 12 : isTablet ? 20 : 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: FormBuilderTextField(
            name: 'name',
            style: TextStyle(
              fontSize: isMobile ? 16.sp : isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isMobile ? 16.sp : isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(
                    isMobile ? 10.w : isTablet ? 14.w : 12.w),
                padding: EdgeInsets.all(isMobile ? 6.w : isTablet ? 10.w : 8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      isMobile ? 6.r : isTablet ? 10.r : 8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.user,
                  size: isMobile ? 14.sp : isTablet ? 18.sp : 16.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.w : isTablet ? 24.w : 20.w,
                vertical: isMobile ? 14.h : isTablet ? 20.h : 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Name is required'),
              FormBuilderValidators.minLength(
                  2, errorText: 'Name must be at least 2 characters'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint
    final isMobile = screenWidth <= 768; // Updated breakpoint

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: isMobile ? 15.sp : isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isMobile ? 10.h : 8.h),
        Container(
          height: isMobile ? 52.h : isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                isMobile ? 12.r : isTablet ? 16.r : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isMobile ? 12 : isTablet ? 20 : 15,
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
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: isMobile ? 16.sp : isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isMobile ? 16.sp : isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(
                    isMobile ? 10.w : isTablet ? 14.w : 12.w),
                padding: EdgeInsets.all(isMobile ? 6.w : isTablet ? 10.w : 8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                      isMobile ? 6.r : isTablet ? 10.r : 8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.envelope,
                  size: isMobile ? 14.sp : isTablet ? 18.sp : 16.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    isMobile ? 12.r : isTablet ? 16.r : 14.r),
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.w : isTablet ? 24.w : 20.w,
                vertical: isMobile ? 14.h : isTablet ? 20.h : 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email is required'),
              FormBuilderValidators.email(
                  errorText: 'Please enter a valid email'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: isTablet ? 20 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePassword,
            onChanged: (value) => _checkPasswordStrength(value ?? ''),
            style: TextStyle(
              fontSize: isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.w : 20.w,
                vertical: isTablet ? 20.h : 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                  size: isTablet ? 24 : 20,
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
                  8, errorText: 'Password must be at least 8 characters'),
                  (value) {
                if (value == null || value.isEmpty) return null;

                // Check for at least one lowercase letter
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }

                // Check for at least one uppercase letter  
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }

                // Check for at least one digit
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }

                return null;
              },
            ]),
          ),
        ),
        SizedBox(height: 8.h),
        _buildPasswordStrengthIndicator(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _passwordStrengthValue,
                backgroundColor: Colors.grey[300],
                color: _passwordStrengthColor,
                minHeight: 4.h,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              _passwordStrength,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Password must contain: uppercase, lowercase, number, and be 8+ characters',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 60.h : 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: isTablet ? 20 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FormBuilderTextField(
            name: 'confirmPassword',
            obscureText: _obscureConfirmPassword,
            style: TextStyle(
              fontSize: isTablet ? 18.sp : 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 18.sp : 16.sp,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16.r : 14.r),
                borderSide: BorderSide(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.w : 20.w,
                vertical: isTablet ? 20.h : 16.h,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons
                      .visibility_off,
                  color: Colors.grey[600],
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: 'Please confirm your password'),
                  (value) {
                final password = _formKey.currentState?.fields['password']
                    ?.value;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth <= 360; // Very small phones
    final isMobile = screenWidth <= 768; // Mobile view

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.w : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: isSmallScreen ? 0.8 : 0.9,
            child: Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 2.w : 4.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _acceptTerms = !_acceptTerms;
                });
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.sp : isMobile ? 16.sp : 14.sp,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                maxLines: isSmallScreen ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRegisterButton() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint
    final isMobile = screenWidth <= 768; // Updated breakpoint

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
            onPressed: authProvider.isLoading ? null : _handleRegister,
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
                    'Create Account',
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

  Widget _buildEnhancedGoogleButton() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth > 768 &&
        screenWidth <= 1200; // Updated breakpoint
    final isMobile = screenWidth <= 768; // Updated breakpoint

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

  Widget _buildSignInSection() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isMobile = screenWidth <= 768; // Mobile view

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isMobile ? 16.sp : 15.sp, // Increased mobile font size
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: isMobile ? 17.sp : 15.sp, // Increased mobile font size
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    String strengthText = 'Weak';
    Color strengthColor = Colors.red;

    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    if (strength <= 0.2) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 0.4) {
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else if (strength <= 0.6) {
      strengthText = 'Good';
      strengthColor = Colors.yellow[700]!;
    } else if (strength <= 0.8) {
      strengthText = 'Strong';
      strengthColor = Colors.lightGreen;
    } else {
      strengthText = 'Very Strong';
      strengthColor = Colors.green;
    }

    setState(() {
      _passwordStrength = strengthText;
      _passwordStrengthValue = strength;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      _showErrorSnackBar('Please accept the terms and conditions');
      return;
    }

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUpWithEmailPassword(
        email: formData['email'],
        password: formData['password'],
        name: formData['name'],
      );

      if (!mounted) return; // Check if widget is still mounted

      if (success) {
        _showSuccessSnackBar('Account created successfully! Welcome aboard! 🎉');

        // Navigate after a brief delay to show the success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const PortfolioScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        });
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Registration failed');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _showSuccessSnackBar('Welcome! Signed in successfully! 🎉');

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const PortfolioScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation,
                  child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Google sign-in failed');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return; // Safety check

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
    if (!mounted) return; // Safety check

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
