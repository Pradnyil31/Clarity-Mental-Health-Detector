/// Centralized spacing and dimension constants for the Clarity app.
/// Base unit: 4px, following 4pt grid system.
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base spacing units (4px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Common use case spacing
  static const double cardPadding = 20.0;
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
  static const double elementSpacing = 16.0;
  
  // Vertical spacing
  static const double verticalXs = 4.0;
  static const double verticalSm = 8.0;
  static const double verticalMd = 16.0;
  static const double verticalLg = 24.0;
  static const double verticalXl = 32.0;
  
  // Horizontal spacing
  static const double horizontalXs = 4.0;
  static const double horizontalSm = 8.0;
  static const double horizontalMd = 16.0;
  static const double horizontalLg = 24.0;
  static const double horizontalXl = 32.0;
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  // Private constructor to prevent instantiation
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // Component-specific radius
  static const double button = 28.0;
  static const double card = 16.0;
  static const double cardLarge = 20.0;
  static const double dialog = 20.0;
  static const double sheet = 24.0;
  static const double chip = 12.0;
  static const double avatar = 24.0;
}

/// Elevation constants for consistent shadows
class AppElevation {
  // Private constructor to prevent instantiation
  AppElevation._();

  static const double none = 0.0;
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
  static const double extraHigh = 16.0;
}

/// Icon size constants
class AppIconSize {
  // Private constructor to prevent instantiation
  AppIconSize._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 28.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Common dimensions for interactive elements
class AppDimensions {
  // Private constructor to prevent instantiation
  AppDimensions._();

  // Button heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;
  
  // App bar heights
  static const double appBarHeight = 56.0;
  static const double appBarExpandedHeight = 200.0;
  
  // Bottom navigation
  static const double bottomNavHeight = 80.0;
  
  // Card dimensions
  static const double cardMinHeight = 100.0;
  static const double cardMaxWidth = 400.0;
  
  // Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarExtraLarge = 96.0;
}
