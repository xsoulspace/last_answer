
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/common_imports.dart';

/// The world inspector as a standalone full-screen page (ADR 0023:
/// observability lives in Settings/a menu, not embedded under every
/// doc). The pane self-polls and converges within one tick; the binding
/// pick persists through [onBindingChanged] (null = the embedded
/// default over the ONE session registry).
final class WorldInspectorFullScreenPage extends StatelessWidget {
  const WorldInspectorFullScreenPage({
    this.binding,
    this.onBindingChanged,
    super.key,
  });

  final WorldBindingModel? binding;
  final ValueChanged<WorldBindingModel?>? onBindingChanged;

  @override
  Widget build(final BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'WORLD INSPECTOR',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('world_inspector.fullscreen.close'),
                tooltip: 'Close',
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Gap(8),
            ],
          ),
          Expanded(
            child: WorldInspectorPane(
              expandedHeight: double.infinity,
              binding: binding,
              onBindingChanged:
                  onBindingChanged ?? (final _) {},
            ),
          ),
        ],
      ),
    ),
  );
}
