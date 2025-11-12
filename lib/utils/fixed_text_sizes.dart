import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FixedTextSizes {
  // Heading sizes - fixed for consistency
  static const double h1 = 36.0;
  static const double h2 = 32.0;
  static const double h3 = 28.0;
  static const double h4 = 24.0;
  static const double h5 = 20.0;
  static const double h6 = 18.0;

  // Display sizes - for large titles
  static const double displayLarge = 48.0;
  static const double displayMedium = 36.0;
  static const double displaySmall = 28.0;

  // Body text sizes - fixed for readability
  static const double bodyLarge = 18.0;
  static const double body = 16.0;
  static const double bodySmall = 14.0;
  static const double caption = 12.0;
  static const double overline = 10.0;

  // Alternative names for consistency
  static const double bodyText = 16.0;
  static const double bodyTextSmall = 14.0;
  static const double captionText = 12.0;
  static const double overlineText = 10.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;

  // Hero section specific sizes
  static const double heroTitle = 48.0;
  static const double heroSubtitle = 24.0;
  static const double heroDescription = 18.0;

  // Special fixed sizes for specific UI elements
  static const double button = 16.0;
  static const double buttonText = 16.0;
  static const double buttonLarge = 18.0;
  static const double buttonMedium = 16.0;
  static const double buttonSmall = 14.0;
  static const double tabText = 14.0;
  static const double cardTitle = 18.0;
  static const double cardSubtitle = 14.0;
  static const double appBarTitle = 20.0;
  static const double drawerItem = 16.0;

  // Form field sizes
  static const double fieldLabel = 14.0;
  static const double fieldText = 16.0;
  static const double fieldHint = 14.0;
  static const double fieldError = 12.0;

  // Navigation and menu sizes
  static const double navItem = 16.0;
  static const double menuItem = 14.0;
  static const double breadcrumb = 12.0;

  // Common text style factories with fixed sizes
  static TextStyle headingStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: h2,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).textTheme.headlineMedium?.color,
    );
  }

  static TextStyle bodyStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: body,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle buttonStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: button,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white,
    );
  }

  static TextStyle captionStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: caption,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).textTheme.bodySmall?.color,
    );
  }

  static TextStyle fieldLabelStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: fieldLabel,
      fontWeight: FontWeight.w500,
      color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
    );
  }

  static TextStyle fieldTextStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: fieldText,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }
}