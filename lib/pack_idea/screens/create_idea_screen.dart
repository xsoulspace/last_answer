import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

part 'create_idea_screen_state.dart';

class CreateIdeaProjectScreen extends HookWidget {
  const CreateIdeaProjectScreen({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final effectiveInputDecoration = const InputDecoration()
        .applyDefaults(
          Theme.of(context).inputDecorationTheme,
        )
        .copyWith(
          hintText: S.current.createIdeaHelperText,
          border: const UnderlineInputBorder(),
        );

    final state = _useCreateIdeaScreenState();

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: BackTextUniversalAppBar(
        titleStr: '',
        onBack: state.onBack,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ScreenLayout.maxFullscreenPageWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IconIdeaButton(size: 76),
                  const SizedBox(height: 44),
                  Text(
                    S.current.whatsYourIdea,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 87),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          onSubmitted: (final _) => state.onCreate(),
                          focusNode: state._textFieldFocusNode,
                          controller: state.textController,
                          maxLength: 90,
                          style: Theme.of(context).textTheme.headline1,
                          decoration: effectiveInputDecoration,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: state.onCreate,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
