import 'package:flutter/material.dart';

/// {@template ai_layout_context}
/// Context information for AI layout generation
///
/// Contains all necessary information for the AI system to generate
/// appropriate layouts based on content, user behavior, and environment.
/// {@endtemplate}
class AILayoutContext {
  /// {@macro ai_layout_context}
  const AILayoutContext({
    required this.contentType,
    required this.screenSize,
    required this.deviceType,
    this.userBehaviorPatterns = const [],
    this.timeOfDay,
    this.contentPriority = const [],
    this.aestheticPreferences,
    this.accessibilityRequirements,
  });

  /// Type of content being laid out
  final LayoutContentType contentType;

  /// Available screen dimensions
  final Size screenSize;

  /// Device type for layout optimization
  final DeviceType deviceType;

  /// Historical user interaction patterns
  final List<UserBehaviorPattern> userBehaviorPatterns;

  /// Current time context for adaptive layouts
  final TimeOfDay? timeOfDay;

  /// Content priority ranking for layout hierarchy
  final List<ContentPriority> contentPriority;

  /// User's aesthetic preferences
  final AestheticPreferences? aestheticPreferences;

  /// Accessibility requirements to consider
  final AccessibilityRequirements? accessibilityRequirements;
}

/// {@template ai_layout_config}
/// Configuration for AI layout generation
///
/// Controls the behavior and constraints of the AI layout system.
/// {@endtemplate}
class AILayoutConfig {
  /// {@macro ai_layout_config}
  const AILayoutConfig({
    this.layoutStyle = AILayoutStyle.adaptive,
    this.creativityLevel = 0.6,
    this.performanceMode = PerformanceMode.balanced,
    this.enableExperimental = false,
    this.maxLayoutVariations = 3,
    this.layoutConstraints,
  });

  /// Overall layout style approach
  final AILayoutStyle layoutStyle;

  /// Creativity level (0.0 = conservative, 1.0 = highly creative)
  final double creativityLevel;

  /// Performance optimization mode
  final PerformanceMode performanceMode;

  /// Enable experimental layout features
  final bool enableExperimental;

  /// Maximum number of layout variations to generate
  final int maxLayoutVariations;

  /// Hard constraints for layout generation
  final LayoutConstraints? layoutConstraints;
}

/// {@template ai_layout_result}
/// Result of AI layout generation
///
/// Contains the generated layout configuration and metadata.
/// {@endtemplate}
class AILayoutResult {
  /// {@macro ai_layout_result}
  const AILayoutResult({
    required this.layoutTree,
    required this.confidence,
    required this.generationTime,
    this.alternatives = const [],
    this.reasoning,
    this.performanceMetrics,
  });

  /// Generated layout tree structure
  final LayoutTree layoutTree;

  /// AI confidence in this layout (0.0 - 1.0)
  final double confidence;

  /// Time taken to generate this layout
  final Duration generationTime;

  /// Alternative layout options
  final List<LayoutTree> alternatives;

  /// AI reasoning for layout decisions
  final String? reasoning;

  /// Performance metrics for this generation
  final PerformanceMetrics? performanceMetrics;
}

/// Enumeration of content types for layout optimization
enum LayoutContentType {
  article,
  gallery,
  form,
  dashboard,
  social,
  ecommerce,
  gaming,
  educational,
  creative,
  mixed,
}

/// Device type classification for responsive design
enum DeviceType { mobile, tablet, desktop, tv, watch, foldable }

/// AI layout generation styles
enum AILayoutStyle {
  conservative,
  adaptive,
  creative,
  experimental,
  brandAligned,
}

/// Performance optimization modes
enum PerformanceMode { fast, balanced, quality, batteryOptimized }

/// {@template user_behavior_pattern}
/// Represents a user's interaction pattern
/// {@endtemplate}
class UserBehaviorPattern {
  /// {@macro user_behavior_pattern}
  const UserBehaviorPattern({
    required this.interactionType,
    required this.frequency,
    required this.duration,
    this.timeContext,
    this.deviceContext,
  });

  final InteractionType interactionType;
  final double frequency;
  final Duration duration;
  final TimeOfDay? timeContext;
  final DeviceType? deviceContext;
}

/// Types of user interactions
enum InteractionType {
  tap,
  longPress,
  scroll,
  swipe,
  pinch,
  drag,
  hover,
  focus,
}

/// {@template content_priority}
/// Defines content importance for layout hierarchy
/// {@endtemplate}
class ContentPriority {
  /// {@macro content_priority}
  const ContentPriority({
    required this.contentId,
    required this.priority,
    required this.importance,
  });

  final String contentId;
  final int priority;
  final double importance;
}

/// {@template aesthetic_preferences}
/// User's aesthetic preferences for layout generation
/// {@endtemplate}
class AestheticPreferences {
  /// {@macro aesthetic_preferences}
  const AestheticPreferences({
    this.colorScheme,
    this.spacing = SpacingPreference.balanced,
    this.typography = TypographyPreference.readable,
    this.layoutDensity = LayoutDensity.comfortable,
    this.animationPreference = AnimationPreference.subtle,
  });

  final ColorScheme? colorScheme;
  final SpacingPreference spacing;
  final TypographyPreference typography;
  final LayoutDensity layoutDensity;
  final AnimationPreference animationPreference;
}

/// Spacing preference options
enum SpacingPreference { compact, balanced, generous, minimal }

/// Typography preference options
enum TypographyPreference { readable, compact, expressive, minimal }

/// Layout density options
enum LayoutDensity { compact, comfortable, spacious }

/// Animation preference options
enum AnimationPreference { none, minimal, subtle, expressive }

/// {@template accessibility_requirements}
/// Accessibility requirements for inclusive layout generation
/// {@endtemplate}
class AccessibilityRequirements {
  /// {@macro accessibility_requirements}
  const AccessibilityRequirements({
    this.screenReader = false,
    this.highContrast = false,
    this.largeText = false,
    this.reducedMotion = false,
    this.colorBlindness,
    this.motorImpairment = false,
  });

  final bool screenReader;
  final bool highContrast;
  final bool largeText;
  final bool reducedMotion;
  final ColorBlindnessType? colorBlindness;
  final bool motorImpairment;
}

/// Types of color blindness
enum ColorBlindnessType { protanopia, deuteranopia, tritanopia, achromatopsia }

/// {@template layout_tree}
/// Hierarchical layout structure generated by AI
/// {@endtemplate}
class LayoutTree {
  /// {@macro layout_tree}
  const LayoutTree({required this.rootNode, required this.metadata});

  final LayoutNode rootNode;
  final LayoutMetadata metadata;
}

/// {@template layout_node}
/// Individual node in the layout tree
/// {@endtemplate}
class LayoutNode {
  /// {@macro layout_node}
  const LayoutNode({
    required this.id,
    required this.type,
    required this.bounds,
    this.children = const [],
    this.properties = const {},
    this.constraints,
  });

  final String id;
  final LayoutNodeType type;
  final Rect bounds;
  final List<LayoutNode> children;
  final Map<String, dynamic> properties;
  final BoxConstraints? constraints;
}

/// Types of layout nodes
enum LayoutNodeType {
  container,
  text,
  image,
  button,
  input,
  list,
  grid,
  custom,
}

/// {@template layout_constraints}
/// Hard constraints for layout generation
/// {@endtemplate}
class LayoutConstraints {
  /// {@macro layout_constraints}
  const LayoutConstraints({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.aspectRatio,
    this.safeArea = true,
    this.excludedAreas = const [],
  });

  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final double? aspectRatio;
  final bool safeArea;
  final List<Rect> excludedAreas;
}

/// {@template layout_metadata}
/// Metadata about the generated layout
/// {@endtemplate}
class LayoutMetadata {
  /// {@macro layout_metadata}
  const LayoutMetadata({
    required this.generatedAt,
    required this.version,
    this.tags = const [],
    this.complexity,
    this.adaptability,
  });

  final DateTime generatedAt;
  final String version;
  final List<String> tags;
  final double? complexity;
  final double? adaptability;
}

/// {@template performance_metrics}
/// Performance metrics for layout generation
/// {@endtemplate}
class PerformanceMetrics {
  /// {@macro performance_metrics}
  const PerformanceMetrics({
    required this.generationTime,
    required this.memoryUsage,
    required this.cpuUsage,
    this.cacheHitRate,
    this.networkRequests,
  });

  final Duration generationTime;
  final int memoryUsage;
  final double cpuUsage;
  final double? cacheHitRate;
  final int? networkRequests;
}
