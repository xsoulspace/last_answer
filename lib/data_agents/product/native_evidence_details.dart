import 'package:flutter/widgets.dart';
import 'package:la_ui_kit/la_ui_kit.dart';

/// Plain text disclosure on the document grid, without ListTile chrome.
/// Extracted from the retired meaning experiment view (ADR 0023): the
/// native receipt/permission rows still need it, the experiment does not.
final class NativeEvidenceDetails extends StatefulWidget {
  const NativeEvidenceDetails({
    required this.title,
    this.body,
    this.child,
    this.surfaceKey,
    super.key,
  });
  final String title;
  final String? body;
  final Widget? child;
  final Key? surfaceKey;
  @override
  State<NativeEvidenceDetails> createState() => _NativeEvidenceDetailsState();
}

class _NativeEvidenceDetailsState extends State<NativeEvidenceDetails>
    with AutomaticKeepAliveClientMixin {
  bool expanded = false;
  @override
  bool get wantKeepAlive => expanded;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LaButton(
          key: widget.surfaceKey,
          variant: LaButtonVariant.ghost,
          onPressed: () {
            setState(() => expanded = !expanded);
            updateKeepAlive();
          },
          label: '${expanded ? '−' : '+'} ${widget.title}',
        ),
        if (expanded) ...[
          if (widget.child != null) widget.child!,
          if (widget.body != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                primary: false,
                child: LaSelectableText(widget.body!, style: context.laUi.mono),
              ),
            ),
        ],
      ],
    );
  }
}
