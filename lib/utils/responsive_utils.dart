import 'package:flutter/material.dart';

/// Centralized responsive design utilities for the Clarity app.
/// Provides breakpoints, responsive sizing, and adaptive layout helpers.
class ResponsiveUtils {
  // Screen size breakpoints (based on width in logical pixels)
  static const double _smallPhoneBreakpoint = 375.0;
  static const double _mediumPhoneBreakpoint = 414.0;
  static const double _tabletBreakpoint = 768.0;

  /// Returns true if the screen width is less than 375px (small phones)
  /// Examples: iPhone SE, Samsung Galaxy S10e, Pixel 4a
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallPhoneBreakpoint;
  }

  /// Returns true if the screen width is between 375px and 414px (medium phones)
  /// Examples: iPhone 12/14, Samsung Galaxy S21, Pixel 6
  static bool isMediumPhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _smallPhoneBreakpoint && width < _mediumPhoneBreakpoint;
  }

  /// Returns true if the screen width is between 414px and 768px (large phones)
  /// Examples: iPhone Pro Max, Samsung S23 Ultra, Pixel 7 Pro
  static bool isLargePhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mediumPhoneBreakpoint && width < _tabletBreakpoint;
  }

  /// Returns true if the screen width is 768px or greater (tablets)
  /// Examples: iPad, Samsung Galaxy Tab
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= _tabletBreakpoint;
  }

  /// Returns responsive horizontal padding based on screen size
  /// Small: 12px, Medium: 16px, Large: 20px, Tablet: 24px
  static double horizontalPadding(BuildContext context) {
    if (isSmallPhone(context)) return 12.0;
    if (isMediumPhone(context)) return 16.0;
    if (isLargePhone(context)) return 20.0;
    return 24.0; // tablet
  }

  /// Returns responsive vertical padding based on screen size
  /// Small: 12px, Medium: 16px, Large: 20px, Tablet: 24px
  static double verticalPadding(BuildContext context) {
    if (isSmallPhone(context)) return 12.0;
    if (isMediumPhone(context)) return 16.0;
    if (isLargePhone(context)) return 20.0;
    return 24.0; // tablet
  }

  /// Returns responsive EdgeInsets for symmetric padding
  static EdgeInsets symmetricPadding(BuildContext context) {
    final horizontal = horizontalPadding(context);
    final vertical = verticalPadding(context);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Returns responsive EdgeInsets for all-around padding
  static EdgeInsets allPadding(BuildContext context) {
    final padding = horizontalPadding(context);
    return EdgeInsets.all(padding);
  }

  /// Returns responsive font size based on screen size
  /// Params: small (for small phones), medium (for medium phones), large (for large phones/tablets)
  static double fontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallPhone(context)) return small;
    if (isMediumPhone(context)) return medium;
    return large;
  }

  /// Returns responsive icon size based on screen size
  /// Small: 20px, Medium: 24px, Large: 28px
  static double iconSize(BuildContext context,
      {double? small, double? medium, double? large}) {
    if (isSmallPhone(context)) return small ?? 20.0;
    if (isMediumPhone(context)) return medium ?? 24.0;
    return large ?? 28.0;
  }

  /// Returns responsive number of grid columns
  /// Small/Medium/Large phones: 2 columns, Tablets: 3-4 columns
  static int gridColumns(BuildContext context, {int tabletColumns = 4}) {
    if (isTablet(context)) return tabletColumns;
    return 2; // default for all phones
  }

  /// Returns responsive grid aspect ratio
  /// Adjusts based on screen size to prevent items from being too tall or too wide
  static double gridAspectRatio(BuildContext context,
      {double small = 1.2, double medium = 1.4, double large = 1.5}) {
    if (isSmallPhone(context)) return small;
    if (isMediumPhone(context)) return medium;
    return large;
  }

  /// Returns responsive spacing between elements
  /// Small: 8px, Medium: 12px, Large: 16px
  static double spacing(BuildContext context,
      {double? small, double? medium, double? large}) {
    if (isSmallPhone(context)) return small ?? 8.0;
    if (isMediumPhone(context)) return medium ?? 12.0;
    return large ?? 16.0;
  }

  /// Returns responsive button height
  /// Small: 44px (minimum touch target), Medium: 48px, Large: 52px
  static double buttonHeight(BuildContext context) {
    if (isSmallPhone(context)) return 44.0;
    if (isMediumPhone(context)) return 48.0;
    return 52.0;
  }

  /// Returns responsive app bar height
  /// Small: 56px, Medium: 64px, Large: 72px
  static double appBarHeight(BuildContext context) {
    if (isSmallPhone(context)) return 56.0;
    if (isMediumPhone(context)) return 64.0;
    return 72.0;
  }

  /// Returns responsive bottom navigation bar height
  /// Small: 56px, Medium: 64px, Large: 72px
  static double bottomBarHeight(BuildContext context) {
    if (isSmallPhone(context)) return 56.0;
    if (isMediumPhone(context)) return 64.0;
    return 72.0;
  }

  /// Returns responsive card border radius
  /// Small: 12px, Medium: 14px, Large: 16px
  static double cardBorderRadius(BuildContext context) {
    if (isSmallPhone(context)) return 12.0;
    if (isMediumPhone(context)) return 14.0;
    return 16.0;
  }

  /// Returns responsive maximum width for content (useful for tablets)
  /// Prevents content from stretching too wide on large screens
  static double maxContentWidth(BuildContext context) {
    if (isTablet(context)) return 600.0;
    return double.infinity;
  }

  /// Returns responsive avatar/profile picture size
  /// Small: 40px, Medium: 48px, Large: 56px
  static double avatarSize(BuildContext context,
      {double? small, double? medium, double? large}) {
    if (isSmallPhone(context)) return small ?? 40.0;
    if (isMediumPhone(context)) return medium ?? 48.0;
    return large ?? 56.0;
  }

  /// Returns the screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns responsive value based on a percentage of screen width
  /// Useful for making elements scale proportionally
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  /// Returns responsive value based on a percentage of screen height
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  /// Returns true if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns true if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}
