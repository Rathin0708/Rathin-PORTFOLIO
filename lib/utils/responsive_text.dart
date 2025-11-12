import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveText {
  /// Get responsive font size based on screen width
  static double getFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    if (screenWidth <= 600) return mobile;
    if (screenWidth <= 1200) return tablet;
    return desktop;
  }

  /// Get adaptive font size with scaling factor
  static double getAdaptiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    // Calculate scaling factor based on screen size
    double scaleFactor = 1.0;

    if (screenWidth <= 360) {
      scaleFactor = 0.85; // Small phones
    } else if (screenWidth <= 414) {
      scaleFactor = 0.9; // Regular phones
    } else if (screenWidth <= 768) {
      scaleFactor = 1.0; // Large phones
    } else if (screenWidth <= 1024) {
      scaleFactor = 1.1; // Tablets
    } else if (screenWidth <= 1440) {
      scaleFactor = 1.2; // Desktop
    } else {
      scaleFactor = 1.3; // Large desktop
    }

    // Adjust for very short screens (landscape mode)
    if (screenHeight < 500) {
      scaleFactor *= 0.9;
    }

    return baseFontSize * scaleFactor;
  }

  /// Display text styles with responsive sizing
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 48.0),
      fontWeight: FontWeight.bold,
      color: color ?? Theme
          .of(context)
          .textTheme
          .displayLarge
          ?.color,
      letterSpacing: -1.5,
      height: 1.1,
    );
  }

  static TextStyle displayMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 36.0),
      fontWeight: FontWeight.bold,
      color: color ?? Theme
          .of(context)
          .textTheme
          .displayMedium
          ?.color,
      letterSpacing: -1.0,
      height: 1.2,
    );
  }

  static TextStyle displaySmall(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 28.0),
      fontWeight: FontWeight.w600,
      color: color ?? Theme
          .of(context)
          .textTheme
          .displaySmall
          ?.color,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  /// Headline text styles with responsive sizing
  static TextStyle headlineLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 24.0),
      fontWeight: FontWeight.w600,
      color: color ?? Theme
          .of(context)
          .textTheme
          .headlineLarge
          ?.color,
      letterSpacing: -0.25,
      height: 1.3,
    );
  }

  static TextStyle headlineMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 20.0),
      fontWeight: FontWeight.w500,
      color: color ?? Theme
          .of(context)
          .textTheme
          .headlineMedium
          ?.color,
      letterSpacing: 0,
      height: 1.3,
    );
  }

  static TextStyle headlineSmall(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 18.0),
      fontWeight: FontWeight.w500,
      color: color ?? Theme
          .of(context)
          .textTheme
          .headlineSmall
          ?.color,
      letterSpacing: 0,
      height: 1.3,
    );
  }

  /// Body text styles with responsive sizing
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 16.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .textTheme
          .bodyLarge
          ?.color,
      letterSpacing: 0.15,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 14.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color,
      letterSpacing: 0.25,
      height: 1.4,
    );
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 12.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .textTheme
          .bodySmall
          ?.color,
      letterSpacing: 0.4,
      height: 1.3,
    );
  }

  /// Label text styles with responsive sizing
  static TextStyle labelLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 14.0),
      fontWeight: FontWeight.w500,
      color: color ?? Theme
          .of(context)
          .textTheme
          .labelLarge
          ?.color,
      letterSpacing: 0.1,
      height: 1.4,
    );
  }

  static TextStyle labelMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 12.0),
      fontWeight: FontWeight.w500,
      color: color ?? Theme
          .of(context)
          .textTheme
          .labelMedium
          ?.color,
      letterSpacing: 0.5,
      height: 1.3,
    );
  }

  static TextStyle labelSmall(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 11.0),
      fontWeight: FontWeight.w500,
      color: color ?? Theme
          .of(context)
          .textTheme
          .labelSmall
          ?.color,
      letterSpacing: 0.5,
      height: 1.2,
    );
  }

  /// Special text styles for specific use cases
  static TextStyle buttonText(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 14.0),
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white,
      letterSpacing: 0.75,
      height: 1.2,
    );
  }

  static TextStyle inputText(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 16.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .textTheme
          .bodyLarge
          ?.color,
      letterSpacing: 0.15,
      height: 1.2,
    );
  }

  static TextStyle hintText(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 16.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .hintColor,
      letterSpacing: 0.15,
      height: 1.2,
    );
  }

  static TextStyle errorText(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 12.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .colorScheme
          .error,
      letterSpacing: 0.25,
      height: 1.3,
    );
  }

  /// Animated text with responsive sizing
  static TextStyle animatedText(BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize != null
          ? getAdaptiveFontSize(context, fontSize)
          : getAdaptiveFontSize(context, 24.0),
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? Theme
          .of(context)
          .primaryColor,
      letterSpacing: -0.25,
      height: 1.2,
    );
  }

  /// Navigation text styles
  static TextStyle navText(BuildContext context,
      {Color? color, bool isActive = false}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 14.0),
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      color: color ?? (isActive
          ? Theme
          .of(context)
          .primaryColor
          : Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color),
      letterSpacing: 0.5,
      height: 1.2,
    );
  }

  /// Card title and subtitle styles
  static TextStyle cardTitle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getAdaptiveFontSize(context, 18.0),
      fontWeight: FontWeight.w600,
      color: color ?? Theme
          .of(context)
          .textTheme
          .headlineSmall
          ?.color,
      letterSpacing: -0.25,
      height: 1.3,
    );
  }

  static TextStyle cardSubtitle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getAdaptiveFontSize(context, 14.0),
      fontWeight: FontWeight.w400,
      color: color ?? Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color,
      letterSpacing: 0.25,
      height: 1.4,
    );
  }

  /// Helper method to check if text should be truncated based on screen size
  static int getMaxLines(BuildContext context, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    if (screenWidth <= 600) return mobile;
    if (screenWidth <= 1200) return tablet;
    return desktop;
  }

  /// Get text scale factor based on device settings and screen size
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceTextScale = mediaQuery.textScaleFactor;
    final screenWidth = mediaQuery.size.width;

    // Limit text scaling on small screens to prevent overflow
    if (screenWidth <= 360 && deviceTextScale > 1.2) {
      return 1.2;
    } else if (screenWidth <= 600 && deviceTextScale > 1.3) {
      return 1.3;
    }

    return deviceTextScale;
  }

  /// Create a responsive text widget with automatic overflow handling
  static Widget responsiveText(String text,
      BuildContext context, {
        TextStyle? style,
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        bool softWrap = true,
      }) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    // Auto-determine max lines if not specified
    int defaultMaxLines = maxLines ?? (screenWidth <= 600 ? 2 : 3);

    return Text(
      text,
      style: style ?? bodyLarge(context),
      textAlign: textAlign,
      maxLines: defaultMaxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: softWrap,
      textScaleFactor: getTextScaleFactor(context),
    );
  }
}