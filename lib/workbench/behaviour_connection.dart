import 'package:flutter/material.dart';

/// An executable connection has a direct handle plus a selection alternative.
/// Dropping inserts/removes the supported operation in a candidate, never adopts.
class BehaviourConnection extends StatefulWidget {
  const BehaviourConnection({
    required this.restore,
    required this.onStage,
    super.key,
  });
  final bool restore;
  final ValueChanged<bool> onStage;
  @override
  State<BehaviourConnection> createState() => _BehaviourConnectionState();
}

class _BehaviourConnectionState extends State<BehaviourConnection> {
  bool armed = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Select or drag an operation onto the connection'),
      const SizedBox(height: 12),
      Row(
        children: [
          const Text('Project'),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (d) => d.data == 'restore',
              onAcceptWithDetails: (_) {
                widget.onStage(!widget.restore);
                setState(() => armed = false);
              },
              builder: (context, candidates, rejected) => Semantics(
                label: 'Project opening edge. Insert or remove restoration.',
                button: true,
                child: InkWell(
                  key: const ValueKey('project-opening-edge'),
                  onTap: () {
                    if (armed) {
                      widget.onStage(!widget.restore);
                      setState(() => armed = false);
                    } else {
                      setState(() => armed = true);
                    }
                  },
                  child: SizedBox(
                    height: 64,
                    child: CustomPaint(
                      painter: _EdgePainter(
                        active: armed || candidates.isNotEmpty,
                      ),
                      child: Center(
                        child: Text(
                          widget.restore
                              ? 'open → restore → focus'
                              : 'open → focus',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Text('Editor'),
        ],
      ),
      Draggable<String>(
        data: 'restore',
        feedback: Material(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.restore ? 'Remove restoration' : 'Restore position',
            ),
          ),
        ),
        child: TextButton(
          key: const ValueKey('restore-operation'),
          onPressed: () => setState(() => armed = true),
          child: Text(
            armed
                ? 'Choose the opening edge'
                : widget.restore
                ? 'Remove restoration'
                : 'Restore position',
          ),
        ),
      ),
      if (armed)
        TextButton(
          onPressed: () => setState(() => armed = false),
          child: const Text('Cancel connection'),
        ),
    ],
  );
}

class _EdgePainter extends CustomPainter {
  const _EdgePainter({required this.active});
  final bool active;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active ? Colors.teal : Colors.grey
      ..strokeWidth = active ? 3 : 1;
    canvas.drawLine(
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height - 8), 5, paint);
  }

  @override
  bool shouldRepaint(_EdgePainter old) => active != old.active;
}
