import 'package:flutter/material.dart';

import '../ai_layouts.dart';

/// {@template ai_layout_example}
/// Example demonstrating AI-powered layout generation
///
/// Shows how to use the AI layout system to create unusual
/// and dynamic layouts based on different contexts and configurations.
/// {@endtemplate}
class AILayoutExample extends StatefulWidget {
  /// {@macro ai_layout_example}
  const AILayoutExample({super.key});

  @override
  State<AILayoutExample> createState() => _AILayoutExampleState();
}

class _AILayoutExampleState extends State<AILayoutExample> {
  LayoutContentType _selectedContentType = LayoutContentType.article;
  AILayoutStyle _selectedStyle = AILayoutStyle.creative;
  var _creativityLevel = 0.7;

  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = _getDeviceType(screenSize);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Layout Examples'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Controls section
          _buildControls(),

          // AI Layout demonstration
          Expanded(child: _buildAILayoutDemo(screenSize, deviceType)),
        ],
      ),
    );
  }

  Widget _buildControls() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Type Selection
        const Text(
          'Content Type:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: LayoutContentType.values
              .map(
                (final type) => ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: _selectedContentType == type,
                  onSelected: (final selected) {
                    if (selected) {
                      setState(() => _selectedContentType = type);
                    }
                  },
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 16),

        // Layout Style Selection
        const Text(
          'Layout Style:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AILayoutStyle.values
              .map(
                (final style) => ChoiceChip(
                  label: Text(style.name.toUpperCase()),
                  selected: _selectedStyle == style,
                  onSelected: (final selected) {
                    if (selected) {
                      setState(() => _selectedStyle = style);
                    }
                  },
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 16),

        // Creativity Level Slider
        const Text(
          'Creativity Level:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _creativityLevel,
          divisions: 10,
          label: '${(_creativityLevel * 100).round()}%',
          onChanged: (final value) {
            setState(() => _creativityLevel = value);
          },
        ),
      ],
    ),
  );

  Widget _buildAILayoutDemo(
    final Size screenSize,
    final DeviceType deviceType,
  ) {
    final context = _createAILayoutContext(screenSize, deviceType);
    final config = _createAILayoutConfig();

    return AILayoutBuilder(
      context: context,
      config: config,
      onLayoutGenerated: (final result) {
        // Handle layout generation result
        debugPrint('Generated layout with confidence: ${result.confidence}');
        debugPrint(
          'Generation time: ${result.generationTime.inMilliseconds}ms',
        );
      },
      loadingBuilder: (final context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text(
              'AI is generating your layout...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      errorBuilder: (final context, final error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to generate AI layout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}), // Trigger rebuild
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  AILayoutContext _createAILayoutContext(
    final Size screenSize,
    final DeviceType deviceType,
  ) {
    // Select appropriate preset based on content type and device
    switch (_selectedContentType) {
      case LayoutContentType.article:
        return AIContextPresets.mobileArticle(screenSize);
      case LayoutContentType.gallery:
        return AIContextPresets.tabletGallery(screenSize);
      case LayoutContentType.dashboard:
        return AIContextPresets.desktopDashboard(screenSize);
      case LayoutContentType.social:
        return AIContextPresets.mobileSocial(screenSize);
      case LayoutContentType.ecommerce:
        return AIContextPresets.ecommerceBrowsing(screenSize, deviceType);
      case LayoutContentType.gaming:
        return AIContextPresets.gamingInterface(screenSize, deviceType);
      default:
        return AILayoutContext(
          contentType: _selectedContentType,
          screenSize: screenSize,
          deviceType: deviceType,
          aestheticPreferences: LayoutThemePresets.professional,
        );
    }
  }

  AILayoutConfig _createAILayoutConfig() => AILayoutConfig(
    layoutStyle: _selectedStyle,
    creativityLevel: _creativityLevel,
    enableExperimental: _creativityLevel > 0.8,
    maxLayoutVariations: (_creativityLevel * 5).round() + 1,
  );

  DeviceType _getDeviceType(final Size screenSize) {
    if (screenSize.width < 600) {
      return DeviceType.mobile;
    } else if (screenSize.width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}

/// Example gallery showing different AI layout presets
class AILayoutPresetGallery extends StatelessWidget {
  const AILayoutPresetGallery({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = screenSize.width < 600
        ? DeviceType.mobile
        : screenSize.width < 1024
        ? DeviceType.tablet
        : DeviceType.desktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Layout Presets'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPresetDemo(
            'Magazine Layout',
            'Creative asymmetric layout for articles',
            AILayoutPresets.magazine,
            AIContextPresets.mobileArticle(screenSize),
          ),
          const SizedBox(height: 24),
          _buildPresetDemo(
            'Mosaic Gallery',
            'Irregular grid layout for image galleries',
            AILayoutPresets.mosaicGallery,
            AIContextPresets.tabletGallery(screenSize),
          ),
          const SizedBox(height: 24),
          _buildPresetDemo(
            'Fluid Dashboard',
            'Dynamic widget sizing for dashboards',
            AILayoutPresets.fluidDashboard,
            AIContextPresets.desktopDashboard(screenSize),
          ),
          const SizedBox(height: 24),
          _buildPresetDemo(
            'Gaming Interface',
            'High-performance layout for games',
            AILayoutPresets.gaming,
            AIContextPresets.gamingInterface(screenSize, deviceType),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetDemo(
    final String title,
    final String description,
    final AILayoutConfig config,
    final AILayoutContext context,
  ) => Card(
    elevation: 4,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildConfigChips(config),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: AILayoutBuilder(
            context: context,
            config: config,
            loadingBuilder: (final context) =>
                const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    ),
  );

  Widget _buildConfigChips(final AILayoutConfig config) => Wrap(
    spacing: 8,
    children: [
      Chip(
        label: Text(config.layoutStyle.name.toUpperCase()),
        backgroundColor: Colors.blue[100],
      ),
      Chip(
        label: Text('${(config.creativityLevel * 100).round()}% Creative'),
        backgroundColor: Colors.green[100],
      ),
      Chip(
        label: Text(config.performanceMode.name.toUpperCase()),
        backgroundColor: Colors.orange[100],
      ),
    ],
  );
}

/// Minimal example for quick integration
class SimpleAILayoutExample extends StatelessWidget {
  const SimpleAILayoutExample({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AILayoutBuilder(
      context: AILayoutContext(
        contentType: LayoutContentType.mixed,
        screenSize: screenSize,
        deviceType: DeviceType.mobile,
        aestheticPreferences: LayoutThemePresets.minimalist,
      ),
      config: AILayoutPresets.magazine,
    );
  }
}
