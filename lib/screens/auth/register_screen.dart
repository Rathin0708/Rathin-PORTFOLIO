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
import '../../utils/constants.dart';
import '../../utils/fixed_text_sizes.dart';

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
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    // More granular breakpoints for better responsiveness
    final isSmallMobile = screenWidth <= 400;
    final isMobile = screenWidth > 400 && screenWidth <= 600;
    final isLargeMobile = screenWidth > 600 && screenWidth <= 768;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isLargeTablet = screenWidth > 1024 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    final isWebMobile = kIsWeb && screenWidth <= 600;

    // Adaptive container width based on screen size
    double getMaxWidth() {
      if (isSmallMobile) return screenWidth * 0.95;
      if (isMobile) return 450.0;
      if (isLargeMobile) return 500.0;
      if (isTablet) return 540.0;
      if (isLargeTablet) return 580.0;
      return 620.0; // Desktop
    }

    // Adaptive padding based on screen size
    double getPadding() {
      if (isSmallMobile) return 20.0;
      if (isMobile) return 28.0;
      if (isLargeMobile) return 32.0;
      if (isTablet) return 40.0;
      if (isLargeTablet) return 48.0;
      return 56.0; // Desktop
    }

    // Adaptive spacing based on screen size
    double getSpacing(double small, double medium, double large) {
      if (isSmallMobile || isMobile) return small;
      if (isLargeMobile || isTablet) return medium;
      return large; // Desktop
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: getMaxWidth(),
        minWidth: isSmallMobile ? screenWidth * 0.9 : 400.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: getSpacing(16.0, 24.0, 32.0),
        vertical: screenHeight < 700 ? 12.0 : 20.0, // Adaptive vertical margin
      ),
      padding: EdgeInsets.all(getPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getSpacing(16.0, 20.0, 24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: getSpacing(20.0, 25.0, 30.0),
            offset: Offset(0, getSpacing(8.0, 12.0, 16.0)),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: getSpacing(8.0, 12.0, 16.0),
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
            SizedBox(height: getSpacing(20.0, 28.0, 36.0)),
            _buildNameField(),
            SizedBox(height: getSpacing(14.0, 18.0, 22.0)),
            _buildEmailField(),
            SizedBox(height: getSpacing(14.0, 18.0, 22.0)),
            _buildPasswordField(),
            SizedBox(height: getSpacing(12.0, 16.0, 20.0)),
            _buildConfirmPasswordField(),
            SizedBox(height: getSpacing(14.0, 18.0, 22.0)),
            _buildTermsCheckbox(),
            SizedBox(height: getSpacing(20.0, 28.0, 36.0)),
            _buildEnhancedRegisterButton(),
            SizedBox(height: getSpacing(16.0, 20.0, 24.0)),
            _buildEnhancedDivider(),
            SizedBox(height: getSpacing(16.0, 20.0, 24.0)),
            _buildEnhancedGoogleButton(),
            SizedBox(height: getSpacing(20.0, 28.0, 36.0)),
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

    // More responsive logo sizing
    double getLogoSize() {
      if (screenWidth <= 400) return 75.0;
      if (screenWidth <= 600) return 90.0;
      if (screenWidth <= 768) return 100.0;
      if (screenWidth <= 1024) return 110.0;
      if (screenWidth <= 1200) return 120.0;
      return 130.0;
    }

    double getFontSize(double small, double medium, double large) {
      if (screenWidth <= 600) return small;
      if (screenWidth <= 1024) return medium;
      return large;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              Container(
                width: getLogoSize(),
                height: getLogoSize(),
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
                      blurRadius: getLogoSize() * 0.25,
                      offset: Offset(0, getLogoSize() * 0.1),
                    ),
                  ],
                ),
                child: Icon(
                  FontAwesomeIcons.userPlus,
                  size: getLogoSize() * 0.4,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: getFontSize(16.0, 20.0, 24.0)),
              Text(
                'Create Account ',
                style: AppTheme.headingStyle.copyWith(
                  fontSize: getFontSize(26.0, 30.0, 34.0),
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: getFontSize(6.0, 8.0, 10.0)),
              Text(
                'Join our community today',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: getFontSize(14.0, 16.0, 18.0),
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
            fontSize: isMobile ? FixedTextSizes.fieldLabel : isTablet
                ? FixedTextSizes.fieldLabel
                : FixedTextSizes.fieldLabel,
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
              fontSize: isMobile ? FixedTextSizes.bodyText : isTablet
                  ? FixedTextSizes.bodyText
                  : FixedTextSizes.bodyText,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isMobile ? FixedTextSizes.bodyText : isTablet
                    ? FixedTextSizes.bodyText
                    : FixedTextSizes.bodyText,
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
            fontSize: isMobile ? FixedTextSizes.fieldLabel : isTablet
                ? FixedTextSizes.fieldLabel
                : FixedTextSizes.fieldLabel,
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
              fontSize: isMobile ? FixedTextSizes.bodyText : isTablet
                  ? FixedTextSizes.bodyText
                  : FixedTextSizes.bodyText,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isMobile ? FixedTextSizes.bodyText : isTablet
                    ? FixedTextSizes.bodyText
                    : FixedTextSizes.bodyText,
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
            fontSize: FixedTextSizes.fieldLabel,
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
              fontSize: FixedTextSizes.bodyText,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: FixedTextSizes.bodyText,
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
                fontSize: FixedTextSizes.bodyTextSmall,
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
            fontSize: FixedTextSizes.bodyTextSmall,
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
            fontSize: FixedTextSizes.fieldLabel,
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
              fontSize: FixedTextSizes.bodyText,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: FixedTextSizes.bodyText,
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
                    fontSize: isSmallScreen
                        ? FixedTextSizes.bodyTextSmall
                        : isMobile
                        ? FixedTextSizes.bodyTextSmall
                        : FixedTextSizes.bodyTextSmall,
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
                      fontSize: FixedTextSizes.button,
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
                fontSize: FixedTextSizes.bodyTextSmall,
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
                fontSize: FixedTextSizes.button,
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
            fontSize: FixedTextSizes.bodyTextSmall,
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
              fontSize: FixedTextSizes.button,
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
