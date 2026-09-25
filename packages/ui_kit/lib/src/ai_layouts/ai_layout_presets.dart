import 'package:flutter/material.dart';

import 'ai_layout_models.dart';

/// {@template ai_layout_presets}
/// Collection of predefined AI layout configurations
///
/// Provides ready-to-use layout presets for common unusual
/// layout patterns based on research in AI-powered UI generation.
/// {@endtemplate}
class AILayoutPresets {
  const AILayoutPresets._();

  /// Magazine-style asymmetric layout for articles
  static const magazine = AILayoutConfig(
    layoutStyle: AILayoutStyle.creative,
    creativityLevel: 0.8,
    performanceMode: PerformanceMode.quality,
    enableExperimental: true,
  );

  /// Mosaic gallery layout with irregular grids
  static const mosaicGallery = AILayoutConfig(
    layoutStyle: AILayoutStyle.experimental,
    creativityLevel: 0.9,
    enableExperimental: true,
    maxLayoutVariations: 5,
  );

  /// Fluid dashboard with dynamic widget sizing
  static const fluidDashboard = AILayoutConfig(
    creativityLevel: 0.7,
    performanceMode: PerformanceMode.fast,
    maxLayoutVariations: 2,
  );

  /// Asymmetric social media feed
  static const socialFeed = AILayoutConfig(
    layoutStyle: AILayoutStyle.creative,
    performanceMode: PerformanceMode.batteryOptimized,
  );

  /// Conservative business layout
  static const business = AILayoutConfig(
    layoutStyle: AILayoutStyle.conservative,
    creativityLevel: 0.3,
    performanceMode: PerformanceMode.fast,
    maxLayoutVariations: 1,
  );

  /// Experimental artistic layout
  static const artistic = AILayoutConfig(
    layoutStyle: AILayoutStyle.experimental,
    creativityLevel: 1,
    performanceMode: PerformanceMode.quality,
    enableExperimental: true,
    maxLayoutVariations: 7,
  );

  /// Gaming interface layout
  static const gaming = AILayoutConfig(
    layoutStyle: AILayoutStyle.creative,
    creativityLevel: 0.85,
    enableExperimental: true,
    maxLayoutVariations: 4,
  );

  /// Educational content layout
  static const educational = AILayoutConfig(
    creativityLevel: 0.5,
    maxLayoutVariations: 2,
  );
}

/// {@template ai_context_presets}
/// Predefined context configurations for common scenarios
/// {@endtemplate}
class AIContextPresets {
  const AIContextPresets._();

  /// Mobile article reading context
  static AILayoutContext mobileArticle(
    final Size screenSize,
  ) => AILayoutContext(
    contentType: LayoutContentType.article,
    screenSize: screenSize,
    deviceType: DeviceType.mobile,
    contentPriority: [
      const ContentPriority(contentId: 'title', priority: 1, importance: 1),
      const ContentPriority(contentId: 'content', priority: 2, importance: 0.9),
      const ContentPriority(contentId: 'images', priority: 3, importance: 0.7),
    ],
    aestheticPreferences: const AestheticPreferences(),
  );

  /// Tablet gallery browsing context
  static AILayoutContext tabletGallery(final Size screenSize) =>
      AILayoutContext(
        contentType: LayoutContentType.gallery,
        screenSize: screenSize,
        deviceType: DeviceType.tablet,
        userBehaviorPatterns: [
          const UserBehaviorPattern(
            interactionType: InteractionType.swipe,
            frequency: 0.8,
            duration: Duration(milliseconds: 300),
          ),
          const UserBehaviorPattern(
            interactionType: InteractionType.pinch,
            frequency: 0.4,
            duration: Duration(milliseconds: 500),
          ),
        ],
        aestheticPreferences: const AestheticPreferences(
          spacing: SpacingPreference.minimal,
          layoutDensity: LayoutDensity.compact,
        ),
      );

  /// Desktop dashboard context
  static AILayoutContext desktopDashboard(
    final Size screenSize,
  ) => AILayoutContext(
    contentType: LayoutContentType.dashboard,
    screenSize: screenSize,
    deviceType: DeviceType.desktop,
    userBehaviorPatterns: [
      const UserBehaviorPattern(
        interactionType: InteractionType.hover,
        frequency: 0.9,
        duration: Duration(milliseconds: 100),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.tap,
        frequency: 0.7,
        duration: Duration(milliseconds: 50),
      ),
    ],
    contentPriority: [
      const ContentPriority(contentId: 'metrics', priority: 1, importance: 1),
      const ContentPriority(contentId: 'charts', priority: 2, importance: 0.9),
      const ContentPriority(
        contentId: 'controls',
        priority: 3,
        importance: 0.8,
      ),
    ],
    aestheticPreferences: const AestheticPreferences(
      spacing: SpacingPreference.generous,
      layoutDensity: LayoutDensity.spacious,
      animationPreference: AnimationPreference.minimal,
    ),
  );

  /// Mobile social feed context
  static AILayoutContext mobileSocial(final Size screenSize) => AILayoutContext(
    contentType: LayoutContentType.social,
    screenSize: screenSize,
    deviceType: DeviceType.mobile,
    userBehaviorPatterns: [
      const UserBehaviorPattern(
        interactionType: InteractionType.scroll,
        frequency: 0.95,
        duration: Duration(seconds: 30),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.tap,
        frequency: 0.6,
        duration: Duration(milliseconds: 100),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.longPress,
        frequency: 0.2,
        duration: Duration(milliseconds: 800),
      ),
    ],
    contentPriority: [
      const ContentPriority(contentId: 'posts', priority: 1, importance: 1),
      const ContentPriority(contentId: 'stories', priority: 2, importance: 0.8),
      const ContentPriority(contentId: 'ads', priority: 3, importance: 0.3),
    ],
    aestheticPreferences: const AestheticPreferences(
      spacing: SpacingPreference.compact,
      animationPreference: AnimationPreference.expressive,
    ),
  );

  /// E-commerce product browsing context
  static AILayoutContext ecommerceBrowsing(
    final Size screenSize,
    final DeviceType deviceType,
  ) => AILayoutContext(
    contentType: LayoutContentType.ecommerce,
    screenSize: screenSize,
    deviceType: deviceType,
    userBehaviorPatterns: [
      const UserBehaviorPattern(
        interactionType: InteractionType.tap,
        frequency: 0.8,
        duration: Duration(milliseconds: 150),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.scroll,
        frequency: 0.9,
        duration: Duration(seconds: 10),
      ),
    ],
    contentPriority: [
      const ContentPriority(contentId: 'products', priority: 1, importance: 1),
      const ContentPriority(contentId: 'prices', priority: 2, importance: 0.95),
      const ContentPriority(contentId: 'reviews', priority: 3, importance: 0.7),
      const ContentPriority(
        contentId: 'recommendations',
        priority: 4,
        importance: 0.6,
      ),
    ],
    aestheticPreferences: const AestheticPreferences(),
  );

  /// Gaming interface context
  static AILayoutContext gamingInterface(
    final Size screenSize,
    final DeviceType deviceType,
  ) => AILayoutContext(
    contentType: LayoutContentType.gaming,
    screenSize: screenSize,
    deviceType: deviceType,
    userBehaviorPatterns: [
      const UserBehaviorPattern(
        interactionType: InteractionType.tap,
        frequency: 0.95,
        duration: Duration(milliseconds: 50),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.drag,
        frequency: 0.7,
        duration: Duration(milliseconds: 200),
      ),
      const UserBehaviorPattern(
        interactionType: InteractionType.longPress,
        frequency: 0.3,
        duration: Duration(milliseconds: 500),
      ),
    ],
    contentPriority: [
      const ContentPriority(contentId: 'controls', priority: 1, importance: 1),
      const ContentPriority(contentId: 'status', priority: 2, importance: 0.9),
      const ContentPriority(
        contentId: 'inventory',
        priority: 3,
        importance: 0.6,
      ),
      const ContentPriority(contentId: 'chat', priority: 4, importance: 0.4),
    ],
    aestheticPreferences: const AestheticPreferences(
      spacing: SpacingPreference.minimal,
      layoutDensity: LayoutDensity.compact,
      animationPreference: AnimationPreference.expressive,
    ),
  );

  /// Accessibility-focused context
  static AILayoutContext accessibilityFriendly(
    final Size screenSize,
    final DeviceType deviceType,
    final LayoutContentType contentType,
  ) => AILayoutContext(
    contentType: contentType,
    screenSize: screenSize,
    deviceType: deviceType,
    accessibilityRequirements: const AccessibilityRequirements(
      screenReader: true,
      highContrast: true,
      largeText: true,
      reducedMotion: true,
      motorImpairment: true,
    ),
    aestheticPreferences: const AestheticPreferences(
      spacing: SpacingPreference.generous,
      layoutDensity: LayoutDensity.spacious,
      animationPreference: AnimationPreference.none,
    ),
    contentPriority: [
      const ContentPriority(contentId: 'primary', priority: 1, importance: 1),
      const ContentPriority(
        contentId: 'navigation',
        priority: 2,
        importance: 0.9,
      ),
      const ContentPriority(
        contentId: 'secondary',
        priority: 3,
        importance: 0.5,
      ),
    ],
  );
}

/// {@template layout_theme_presets}
/// Predefined aesthetic themes for AI layouts
/// {@endtemplate}
class LayoutThemePresets {
  const LayoutThemePresets._();

  /// Minimalist theme with clean aesthetics
  static const minimalist = AestheticPreferences(
    spacing: SpacingPreference.generous,
    typography: TypographyPreference.minimal,
    layoutDensity: LayoutDensity.spacious,
  );

  /// Dense information theme
  static const dense = AestheticPreferences(
    spacing: SpacingPreference.compact,
    typography: TypographyPreference.compact,
    layoutDensity: LayoutDensity.compact,
    animationPreference: AnimationPreference.minimal,
  );

  /// Expressive creative theme
  static const expressive = AestheticPreferences(
    typography: TypographyPreference.expressive,
    animationPreference: AnimationPreference.expressive,
  );

  /// Professional business theme
  static const professional = AestheticPreferences();

  /// Playful gaming theme
  static const playful = AestheticPreferences(
    spacing: SpacingPreference.minimal,
    typography: TypographyPreference.expressive,
    layoutDensity: LayoutDensity.compact,
    animationPreference: AnimationPreference.expressive,
  );
}

/// {@template constraint_presets}
/// Common layout constraint configurations
/// {@endtemplate}
class ConstraintPresets {
  const ConstraintPresets._();

  /// Mobile-optimized constraints
  static const mobile = LayoutConstraints(minWidth: 320, maxWidth: 480);

  /// Tablet-optimized constraints
  static const tablet = LayoutConstraints(minWidth: 768, maxWidth: 1024);

  /// Desktop-optimized constraints
  static const desktop = LayoutConstraints(
    minWidth: 1024,
    maxWidth: 1920,
    safeArea: false,
  );

  /// Square aspect ratio constraint
  static const square = LayoutConstraints(aspectRatio: 1);

  /// Golden ratio constraint
  static const goldenRatio = LayoutConstraints(aspectRatio: 1.618);

  /// Widescreen constraint
  static const widescreen = LayoutConstraints(aspectRatio: 16 / 9);
}

/// {@template behavior_pattern_presets}
/// Common user behavior patterns for different contexts
/// {@endtemplate}
class BehaviorPatternPresets {
  const BehaviorPatternPresets._();

  /// Typical mobile reading patterns
  static const mobileReading = [
    UserBehaviorPattern(
      interactionType: InteractionType.scroll,
      frequency: 0.9,
      duration: Duration(seconds: 15),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.tap,
      frequency: 0.3,
      duration: Duration(milliseconds: 100),
    ),
  ];

  /// Desktop productivity patterns
  static const desktopProductivity = [
    UserBehaviorPattern(
      interactionType: InteractionType.hover,
      frequency: 0.8,
      duration: Duration(milliseconds: 200),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.tap,
      frequency: 0.9,
      duration: Duration(milliseconds: 50),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.drag,
      frequency: 0.4,
      duration: Duration(milliseconds: 300),
    ),
  ];

  /// Gaming interaction patterns
  static const gaming = [
    UserBehaviorPattern(
      interactionType: InteractionType.tap,
      frequency: 0.95,
      duration: Duration(milliseconds: 30),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.longPress,
      frequency: 0.6,
      duration: Duration(milliseconds: 400),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.swipe,
      frequency: 0.7,
      duration: Duration(milliseconds: 150),
    ),
  ];

  /// Social media browsing patterns
  static const socialBrowsing = [
    UserBehaviorPattern(
      interactionType: InteractionType.scroll,
      frequency: 0.95,
      duration: Duration(seconds: 30),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.tap,
      frequency: 0.7,
      duration: Duration(milliseconds: 100),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.swipe,
      frequency: 0.5,
      duration: Duration(milliseconds: 200),
    ),
  ];

  /// E-commerce shopping patterns
  static const shopping = [
    UserBehaviorPattern(
      interactionType: InteractionType.tap,
      frequency: 0.8,
      duration: Duration(milliseconds: 150),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.scroll,
      frequency: 0.9,
      duration: Duration(seconds: 10),
    ),
    UserBehaviorPattern(
      interactionType: InteractionType.pinch,
      frequency: 0.3,
      duration: Duration(milliseconds: 400),
    ),
  ];
}
