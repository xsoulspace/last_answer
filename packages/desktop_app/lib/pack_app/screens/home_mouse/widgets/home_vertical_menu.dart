import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

class HomeVerticalMenu extends StatelessWidget {
  const HomeVerticalMenu({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);

    return ColoredBox(
      color: themeDefiner.useContextTheme
          ? themeDefiner.effectiveTheme.primaryColor.withOpacity(.03)
          : Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _VerticalBar(
          onIdeaTap: () => context.read<AppRouterController>().toCreateIdea(),
          onNoteTap: () => context
              .read<AppRouterController>()
              .toNoteScreen(context: context),
          onFolderTap: (final folder) => context
              .read<AppRouterController>()
              .toFolder(folder: folder, read: context.read),
        ),
      ),
    );
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar({
    required this.onIdeaTap,
    required this.onNoteTap,
    required this.onFolderTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onIdeaTap;
  final VoidCallback onNoteTap;
  final ValueChanged<ProjectFolder> onFolderTap;
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);
    final foldersNotifier = context.watch<ProjectFoldersNotifier>();
    final folders = foldersNotifier.state.values.toList();

    return Container(
      margin: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 22,
      ),
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        color: themeDefiner.themeToUse == ThemeToUse.fromContext
            ? Theme.of(context).splashColor.withOpacity(0.05)
            : null,
      ),
      child: CustomScrollView(
        reverse: true,
        slivers: [
          ...[
            BarItem(
              onTap: onIdeaTap,
              label: S.current.idea,
              child: IconIdeaButton(
                onTap: onIdeaTap,
              ),
            ),
            BarItem(
              onTap: onNoteTap,
              label: S.current.note,
              child: IconButton(
                onPressed: onNoteTap,
                icon: const Icon(Icons.book_outlined),
              ),
            ),
            const Divider(),
          ].map(
            (final e) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: e,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListView.separated(
              shrinkWrap: true,
              primary: false,
              itemBuilder: (final context, final index) {
                final folder = folders[index];
                return BarItem(
                  label: folder.title,
                  key: ValueKey(folder),
                  child: InkWell(
                    onTap: () => onFolderTap(folder),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: defaultBorderRadius,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (final context, final index) {
                return const SizedBox(height: 16);
              },
              itemCount: folders.length,
            ),
          ),
        ],
      ),
    );
  }
}

class BarItem extends StatelessWidget {
  const BarItem({
    required this.child,
    required this.label,
    this.onTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback? onTap;
  final Widget child;
  final String label;
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 56,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: child,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
