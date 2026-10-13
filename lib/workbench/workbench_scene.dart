import 'package:ecsly/ecsly.dart';
import 'package:ecsly_flutter_scene/ecsly_flutter_scene.dart';
import 'package:flutter/material.dart';

class _WorkLayer extends Component {
  const _WorkLayer(this.id, this.depth);
  final String id;
  final double depth;
}

/// Selected layer gestures invoke a supported reading-width operation; empty
/// space retains camera navigation. Text stays in accessible Flutter overlays.
class WorkbenchScene extends StatefulWidget {
  const WorkbenchScene({
    required this.onSelect,
    required this.onWidthDelta,
    required this.onEnd,
    super.key,
  });
  final ValueChanged<String> onSelect;
  final ValueChanged<double> onWidthDelta;
  final ValueChanged<bool> onEnd;
  @override
  State<WorkbenchScene> createState() => _WorkbenchSceneState();
}

class _WorkbenchSceneState extends State<WorkbenchScene> {
  late final World world;
  late final SceneMapping mapping;
  @override
  void initState() {
    super.initState();
    world = World();
    world.components.registerObjectComponent<_WorkLayer>();
    for (var i = 0; i < 3; i++) {
      world.spawnComponents([
        _WorkLayer(['layout', 'behaviour', 'state'][i], i.toDouble()),
      ]);
    }
    world.flush();
    mapping = SceneMapping()
      ..add<_WorkLayer>(
        (entity, layer, world) => VisualState(
          shape: SceneShape.sphere,
          argb: 0xff487c7c,
          size: .8,
          position: [(layer.depth - 1) * 3, 0, layer.depth * 1.5],
          label: layer.id,
          pickId: layer.id,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 260,
    child: Stack(
      children: [
        EcsSceneView(
          world: world,
          mapping: mapping,
          initialDistance: 12,
          loadingColor: Theme.of(context).colorScheme.surface,
          onEntityTap: widget.onSelect,
          onManipulationStart: (id) => id == 'layout',
          onManipulationUpdate: (_, dx, dy) => widget.onWidthDelta(dx),
          onManipulationEnd: (_, cancelled) => widget.onEnd(cancelled),
        ),
        const IgnorePointer(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Layout · behaviour · state\nDrag the layout layer to stage reading width.',
            ),
          ),
        ),
      ],
    ),
  );
}
