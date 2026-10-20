/// Initial useful application. Subsequent changes are conventional source
/// authored through the real harness, not predefined feature toggles.
const productJourneySeed = r'''
import 'dart:convert';
import 'dart:html';

final tasks = <Map<String, dynamic>>[
  {'title': 'Outline study', 'priority': 2, 'done': false},
  {'title': 'Review draft', 'priority': 1, 'done': false},
  {'title': 'Send notes', 'priority': 3, 'done': true},
];

void main() {
  final saved = window.localStorage['journey.tasks'];
  if (saved != null) {
    try {
      final rows = (jsonDecode(saved) as List).cast<Map<String, dynamic>>();
      tasks..clear()..addAll(rows);
    } catch (_) {}
  }
  render();
}

void render() {
  final app = querySelector('#app')!;
  app.children.clear();
  app.append(HeadingElement.h1()..text = 'My task board');
  final list = UListElement()..id = 'tasks';
  for (final task in tasks) {
    final checkbox = CheckboxInputElement()..checked = task['done'] as bool;
    checkbox.onChange.listen((_) {
      task['done'] = checkbox.checked ?? false;
      window.localStorage['journey.tasks'] = jsonEncode(tasks);
      render();
    });
    list.append(LIElement()
      ..dataset['priority'] = '${task['priority']}'
      ..dataset['done'] = '${task['done']}'
      ..append(checkbox)
      ..append(SpanElement()..text = '${task['title']} · priority ${task['priority']}'));
  }
  app.append(list);
}
''';
