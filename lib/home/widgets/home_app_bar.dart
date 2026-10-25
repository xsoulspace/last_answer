import 'package:flutter/cupertino.dart';
import 'package:lastanswer/browser/browser_entry.dart';
import 'package:lastanswer/browser/browser_strings.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_entry.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding_sheet.dart';
import 'package:lastanswer/common_imports.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.onInfoTap,
    required this.onSettingsTap,
    super.key,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;

  /// ADR 0003 — a new agent doc. The world picker runs FIRST: the
  /// embedded world is the default (dismiss/pick-embedded both land
  /// there); choosing a discovered or manual world binds the doc to it.
  Future<void> _newAgentDoc(final BuildContext context) async {
    final choice = await showWorldBindingSheet(context);
    if (!context.mounted) return;
    context.read<OpenedProjectNotifier>().createAgentProject(
      context,
      worldBinding: choice.picked ? choice.binding : null,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final greeting = Greeting();
    // final themeDefiner = ThemeDefiner.of(context);
    // final effectiveTheme = themeDefiner.effectiveTheme;

    // if (Platform.isMacOS) {
    //   return LeftPanelMacosAppBar(
    //     context: context,
    //     title: greeting.current,
    //     actions: [
    //       IconButton(
    //         onPressed: onInfoTap,
    //         icon: const Icon(Icons.info_outline),
    //       ),
    //       IconButton(
    //         onPressed: onSettingsTap,
    //         icon: const Icon(CupertinoIcons.settings),
    //       ),
    //     ]
    //         .map(
    //           (final child) => Padding(
    //             padding: const EdgeInsets.only(right: 18),
    //             child: child,
    //           ),
    //         )
    //         .toList(),
    //   );
    // }

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: SelectableText(
              greeting.current,
              style: context.textTheme.labelSmall,
              maxLines: 1,
            ),
            actions:
                [
                      IconButton(
                        key: const Key('home.browser'),
                        onPressed: () =>
                            unawaited(openWorkspaceBrowser(context)),
                        tooltip: BrowserStrings.of(context).windowTitle,
                        icon: const Icon(Icons.web),
                      ),
                      IconButton(
                        key: const Key('home.ask_agent'),
                        onPressed: () => unawaited(_newAgentDoc(context)),
                        tooltip: context.l10n.chat,
                        icon: const Icon(Icons.forum_outlined),
                      ),
                      IconButton(
                        onPressed: onInfoTap,
                        tooltip: 'Info',
                        icon: const Icon(Icons.info_outline),
                      ),
                      IconButton(
                        onPressed: onSettingsTap,
                        tooltip: 'Settings',
                        icon: const Icon(CupertinoIcons.gear),
                      ),
                    ]
                    .map(
                      (final child) => Padding(
                        padding: EdgeInsets.only(
                          right: constraints.maxWidth < 360 ? 0 : 18,
                        ),
                        child: child,
                      ),
                    )
                    .toList(),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: MeaningExperimentEntry(),
            ),
          ),
        ],
      ),
    );
  }
}
