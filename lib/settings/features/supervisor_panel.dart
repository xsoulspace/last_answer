import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/supervisor_service.dart';
import 'package:lastanswer/settings/features/supervisor_view.dart';

/// The device's declared automations, grouped the way a person thinks
/// about them — Services (always on), Schedules (jobs), Agents (agent
/// tasks) — each row a human phrase plus its week at a glance. Authoring
/// happens in one sheet, one or two taps per decision; everything writes
/// validated plan documents (oka ADR-0041 §6). Running remains the
/// converge/resident rung's business, never this pane's.
class SupervisorPanel extends StatefulWidget {
  const SupervisorPanel({super.key});

  @override
  State<SupervisorPanel> createState() => _SupervisorPanelState();
}

class _SupervisorPanelState extends State<SupervisorPanel> {
  SupervisorService? _service;
  Future<SupervisorView>? _view;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final service = await SupervisorService.forDevice();
    if (!mounted) return;
    setState(() {
      _service = service;
      _view = service.load();
    });
  }

  Future<void> _refresh() {
    final service = _service;
    if (service == null) return Future<void>.value();
    // The load starts OUTSIDE setState: a closure that returns a Future
    // trips Flutter's setState assert and the update never lands.
    final future = service.load();
    setState(() {
      _view = future;
    });
    return future;
  }

  Future<void> _save(final SupervisorAutomationDraft draft) async {
    final service = _service;
    if (service == null) return;
    try {
      await service.saveAutomation(draft);
    } on Object catch (error) {
      if (!mounted) return;
      await Toasts.of(context).showBottomToast(message: '$error');
    }
    await _refresh();
  }

  Future<void> _delete(final SupervisorAutomationView automation) async {
    final service = _service;
    final plan = automation.plan;
    if (service == null || plan == null) return;
    await service.deleteAutomation(plan: plan, id: automation.id);
    await _refresh();
  }

  Future<void> _openEditor([final SupervisorAutomationView? existing]) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final result = await showModalBottomSheet<_EditorOutcome>(
      context: context,
      isScrollControlled: true,
      builder: (final context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _AutomationEditorSheet(
          existing: existing,
          title: existing == null
              ? l10n.supervisorSectionAdd
              : l10n.supervisorSectionEdit,
        ),
      ),
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case _EditorAction.save:
        await _save(result.draft!);
      case _EditorAction.delete:
        await _delete(existing!);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.supervisorSectionTitle,
                style: context.textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: l10n.supervisorSectionAdd,
              onPressed: () => unawaited(_openEditor()),
              icon: const Icon(Icons.add),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: l10n.supervisorSectionRefresh,
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        FutureBuilder<SupervisorView>(
          future: _view,
          builder: (final context, final snapshot) {
            final view = snapshot.data;
            if (view == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!view.supported) {
              return Text(
                l10n.supervisorSectionUnsupported,
                style: context.textTheme.bodySmall,
              );
            }
            if (view.automations.isEmpty && view.corruptRecords.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l10n.supervisorSectionEmpty,
                  style: context.textTheme.bodySmall,
                ),
              );
            }
            final services = <SupervisorAutomationView>[];
            final schedules = <SupervisorAutomationView>[];
            final agents = <SupervisorAutomationView>[];
            for (final automation in view.automations) {
              if (automation.isAgent) {
                agents.add(automation);
              } else if (automation.shape == 'service') {
                services.add(automation);
              } else {
                schedules.add(automation);
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _group(l10n.supervisorGroupServices, services),
                _group(l10n.supervisorGroupSchedules, schedules),
                _group(l10n.supervisorGroupAgents, agents),
                for (final corrupt in view.corruptRecords)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      corrupt,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _group(
    final String title,
    final List<SupervisorAutomationView> rows,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final outline = context.theme.colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.bodySmall?.copyWith(
              color: outline,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ),
        for (final automation in rows)
          _AutomationRow(
            automation: automation,
            onEdit: automation.plan == null
                ? null
                : () => unawaited(_openEditor(automation)),
          ),
      ],
    );
  }
}

class _AutomationRow extends StatelessWidget {
  const _AutomationRow({required this.automation, this.onEdit});

  final SupervisorAutomationView automation;
  final VoidCallback? onEdit;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final color = automation.drifted
        ? context.theme.colorScheme.error
        : automation.present
        ? Colors.green
        : context.theme.colorScheme.outline;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(automation.id, style: context.textTheme.bodyMedium),
                    Text(
                      _metaText(l10n),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.outline,
                      ),
                    ),
                    if (automation.isAgent &&
                        (automation.instructions ?? '').isNotEmpty)
                      Text(
                        automation.instructions!
                            .split('\n')
                            .firstWhere(
                              (final line) => line.trim().isNotEmpty,
                              orElse: () => '',
                            )
                            .trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              if (automation.drifted)
                Text(
                  l10n.supervisorSectionDrifted,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.error,
                  ),
                ),
              if (onEdit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: context.theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          if (automation.intervalSeconds != null)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _ScheduleStrip(
                periodSeconds: automation.intervalSeconds!,
                atMinutes: automation.atMinutes,
              ),
            ),
        ],
      ),
    );
    if (onEdit == null) return row;
    return InkWell(onTap: onEdit, child: row);
  }

  /// The human schedule phrase: "Always on", "Daily at 03:00",
  /// "Every 3 days at 03:00", "Every 6 hours", "On demand".
  String _metaText(final S l10n) {
    if (!automation.isAgent && automation.shape == 'service') {
      return l10n.supervisorSectionKindService;
    }
    return _intervalText(l10n);
  }

  String _intervalText(final S l10n) {
    final interval = automation.intervalSeconds;
    if (interval == null) return l10n.supervisorSectionOnDemand;
    final at = automation.atMinutes == null
        ? null
        : _clock(automation.atMinutes!);
    if (interval == 86400) {
      return at == null
          ? l10n.supervisorScheduleDaily
          : l10n.supervisorScheduleDailyAt(at);
    }
    if (interval == 604800) return l10n.supervisorScheduleWeekly;
    if (interval % 86400 == 0) {
      final phrase = l10n.supervisorScheduleEveryDays(interval ~/ 86400);
      return at == null ? phrase : '$phrase ${l10n.supervisorScheduleAt(at)}';
    }
    if (interval % 3600 == 0) {
      return l10n.supervisorScheduleEveryHours(interval ~/ 3600);
    }
    if (interval >= 60) {
      return l10n.supervisorScheduleEveryMinutes(interval ~/ 60);
    }
    return l10n.supervisorScheduleEveryMinutes(1);
  }

  static String _clock(final int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// The schedule as a small calendar: the next seven days, dots on days
/// with planned runs. Present-grade projection — computed from the
/// declared period (and wall-clock anchor when set); the converge rung
/// owns actual firings (ADR-0040/0042).
class _ScheduleStrip extends StatelessWidget {
  const _ScheduleStrip({required this.periodSeconds, this.atMinutes});

  final int periodSeconds;
  final int? atMinutes;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final outline = context.theme.colorScheme.outline;
    final schedule = _PlannedSchedule(
      periodSeconds: periodSeconds,
      atMinutes: atMinutes,
    );
    final first = schedule.firstRun;
    final style = context.textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var day = 0; day < 7; day++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _DayCell(
                    date: DateTime(
                      schedule.today.year,
                      schedule.today.month,
                      schedule.today.day + day,
                    ),
                    runs: schedule.runsPerDay(day),
                    outline: outline,
                  ),
                ),
              ),
          ],
        ),
        if (first != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.supervisorSectionNextRun(_formatTime(first)),
            style: style?.copyWith(color: outline),
          ),
        ],
      ],
    );
  }

  String _formatTime(final DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final clock = _clockOf(time);
    final days = day.difference(today).inDays;
    if (days <= 0) return clock;
    if (days == 1) return '+1d $clock';
    return '+${days}d $clock';
  }

  static String _clockOf(final DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

/// Day cell: weekday letter, day number, one dot per planned run
/// (capped; dense schedules show a full bar).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.runs,
    required this.outline,
  });

  final DateTime date;
  final int runs;
  final Color outline;

  static const _weekdayLetters = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(final BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
    final style = context.textTheme.bodySmall;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday ? outline : outline.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            _weekdayLetters[date.weekday - 1],
            style: style?.copyWith(color: outline, fontSize: 9),
          ),
          Text(
            '${date.day}',
            style: style?.copyWith(
              color: outline,
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : null,
            ),
          ),
          const SizedBox(height: 2),
          if (runs == 0)
            const SizedBox(height: 4)
          else if (runs <= 4)
            for (var i = 0; i < runs; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.5),
                child: Icon(Icons.circle, size: 3, color: outline),
              )
          else
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

/// Prospective run times for an interval schedule, anchored at "now"
/// (plus the wall-clock anchor when set). Pure date math.
final class _PlannedSchedule {
  _PlannedSchedule({required int periodSeconds, this.atMinutes})
    : period = Duration(seconds: periodSeconds);

  final Duration period;
  final int? atMinutes;

  bool get _anchored =>
      atMinutes != null &&
      period >= const Duration(days: 1) &&
      period.inSeconds % 86400 == 0;

  int get _cadenceDays => period.inDays;

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _todayAtAnchor() {
    final anchor = atMinutes;
    if (anchor == null) return null;
    return DateTime(today.year, today.month, today.day, anchor ~/ 60,
        anchor % 60);
  }

  /// The next planned run after "now" (null only for non-positive
  /// periods, which validated plans reject).
  DateTime? get firstRun {
    if (period <= Duration.zero) return null;
    if (!_anchored) return DateTime.now().add(period);
    final slot = _todayAtAnchor()!;
    final cadence = Duration(days: _cadenceDays);
    if (slot.isAfter(DateTime.now())) return slot;
    return slot.add(cadence);
  }

  List<DateTime> upcoming(final int count) {
    final first = firstRun;
    if (first == null) return const <DateTime>[];
    final step =
        _anchored ? Duration(days: _cadenceDays) : period;
    final runs = <DateTime>[first];
    for (var i = 1; i < count; i++) {
      runs.add(runs.last.add(step));
    }
    return runs;
  }

  /// How many runs land on `today + [dayOffset]`, capped at 5 (5+ means
  /// "dense": the strip renders a bar instead of dots).
  int runsPerDay(final int dayOffset) {
    if (period <= Duration.zero) return 0;
    if (_anchored) {
      final first = firstRun!;
      final day = today.add(Duration(days: dayOffset));
      final span = day.difference(DateTime(first.year, first.month, first.day));
      return span.inDays >= 0 && span.inDays % _cadenceDays == 0 ? 1 : 0;
    }
    final dayStart = today.add(Duration(days: dayOffset));
    final dayEnd = dayStart.add(const Duration(days: 1));
    var time = DateTime.now().add(period);
    var runs = 0;
    final horizon = dayStart.add(const Duration(days: 7));
    while (time.isBefore(dayEnd) && time.isBefore(horizon)) {
      if (!time.isBefore(dayStart)) runs++;
      if (runs >= 5) return runs;
      time = time.add(period);
    }
    return runs;
  }
}

enum _EditorAction { save, delete }

final class _EditorOutcome {
  const _EditorOutcome.save(this.draft) : action = _EditorAction.save;
  const _EditorOutcome.delete()
    : action = _EditorAction.delete,
      draft = null;

  final _EditorAction action;
  final SupervisorAutomationDraft? draft;
}

/// Add/edit sheet: what it is (command or agent task), when it runs
/// (one schedule row, human units, optional wall-clock anchor), and
/// what it does. Submits a typed draft; the service owns validation
/// and the plan-document write.
class _AutomationEditorSheet extends StatefulWidget {
  const _AutomationEditorSheet({required this.title, this.existing});

  final String title;
  final SupervisorAutomationView? existing;

  @override
  State<_AutomationEditorSheet> createState() => _AutomationEditorSheetState();
}

class _AutomationEditorSheetState extends State<_AutomationEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _command;
  late final TextEditingController _args;
  late final TextEditingController _instructions;
  late final TextEditingController _interval;
  late final TextEditingController _at;
  late bool _isAgent;
  late bool _isService;
  late bool _repeating;
  late int _intervalUnit; // 60 (min) | 3600 (h) | 86400 (d)

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.id ?? '');
    _command = TextEditingController(text: existing?.command ?? '');
    _args = TextEditingController(text: existing?.args ?? '');
    _instructions = TextEditingController(text: existing?.instructions ?? '');
    _isAgent = existing?.isAgent ?? false;
    _isService = (existing?.shape ?? 'service') != 'job' && !_isAgent;
    final interval = existing?.intervalSeconds;
    _repeating = interval != null;
    final split = _splitPeriod(interval ?? 86400);
    _interval = TextEditingController(text: '${split.$1}');
    _intervalUnit = split.$2;
    _at = TextEditingController(
      text: existing?.atMinutes == null ? '' : _clock(existing!.atMinutes!),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _command.dispose();
    _args.dispose();
    _instructions.dispose();
    _interval.dispose();
    _at.dispose();
    super.dispose();
  }

  static (int, int) _splitPeriod(final int seconds) {
    if (seconds % 86400 == 0) return (seconds ~/ 86400, 86400);
    if (seconds % 3600 == 0) return (seconds ~/ 3600, 3600);
    return (seconds, 60);
  }

  static String _clock(final int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int? get _periodSeconds {
    if (_isService) return null;
    if (!_repeating) return null;
    final value = int.tryParse(_interval.text.trim());
    if (value == null || value <= 0) return null;
    return value * _intervalUnit;
  }

  int? get _atMinutes {
    final text = _at.text.trim();
    if (text.isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }

  bool get _canSave {
    final id = _name.text.trim();
    if (id.isEmpty || id.contains('/') || id.contains('..')) return false;
    final period = _periodSeconds;
    if (!_isService && _repeating && period == null) return false;
    if (!_isService && _repeating && _at.text.trim().isNotEmpty) {
      if (_atMinutes == null) return false;
    }
    if (_isAgent && _instructions.text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _submit() async {
    if (!_canSave) return;
    final id = _name.text.trim();
    if (!mounted) return;
    Navigator.of(context).pop(
      _EditorOutcome.save(
        SupervisorAutomationDraft(
          id: id,
          isService: !_isAgent && _isService,
          command: _isAgent ? null : _command.text.trim(),
          args: _isAgent ? null : _args.text.trim(),
          intervalSeconds: _periodSeconds,
          atMinutes: _periodSeconds != null ? _atMinutes : null,
          isAgent: _isAgent,
          instructions: _isAgent ? _instructions.text.trim() : null,
          plan: widget.existing?.plan,
          revision: widget.existing?.revision ?? 0,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await Modals.of(context).showWarningDialog(
      title: l10n.delete,
      noActionText: l10n.cancel,
      yesActionText: l10n.confirm,
      description: l10n.supervisorSectionDeleteWarn(existing.id),
    );
    if (!confirmed || !mounted) return;
    Navigator.of(context).pop(const _EditorOutcome.delete());
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final outline = context.theme.colorScheme.outline;
    final period = _periodSeconds;
    final existing = widget.existing;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: context.textTheme.titleSmall),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              enabled: !_editing,
              decoration: InputDecoration(
                labelText: l10n.supervisorSectionName,
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.terminal),
                  label: Text(l10n.supervisorSectionKindCommand),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.supervisorSectionKindAgent),
                ),
              ],
              selected: {_isAgent},
              onSelectionChanged: (final selection) =>
                  setState(() => _isAgent = selection.first),
            ),
            const SizedBox(height: 12),
            if (!_isAgent) ...[
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.supervisorSectionKindService),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.schedule),
                    label: Text(l10n.supervisorSectionKindJob),
                  ),
                ],
                selected: {_isService},
                onSelectionChanged: (final selection) =>
                    setState(() => _isService = selection.first),
              ),
            ] else ...[
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.supervisorSectionOnDemand),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.supervisorSectionRepeating),
                  ),
                ],
                selected: {_repeating},
                onSelectionChanged: (final selection) =>
                    setState(() => _repeating = selection.first),
              ),
            ],
            if (!_isService && _repeating) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(l10n.supervisorSectionEvery),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: TextField(
                      controller: _interval,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _intervalUnit,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: 60,
                        child: Text(l10n.supervisorSectionUnitMinutes),
                      ),
                      DropdownMenuItem(
                        value: 3600,
                        child: Text(l10n.supervisorSectionUnitHours),
                      ),
                      DropdownMenuItem(
                        value: 86400,
                        child: Text(l10n.supervisorSectionUnitDays),
                      ),
                    ],
                    onChanged: (final unit) =>
                        setState(() => _intervalUnit = unit ?? 60),
                  ),
                ],
              ),
              if (_intervalUnit == 86400) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(l10n.supervisorSectionAnchorAt),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _at,
                        keyboardType: TextInputType.datetime,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '03:00',
                          isDense: true,
                          errorText: _at.text.trim().isNotEmpty &&
                                  _atMinutes == null
                              ? l10n.supervisorSectionTimeHint
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (period != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.supervisorSectionSchedule,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                _ScheduleStrip(
                  periodSeconds: period,
                  atMinutes: _intervalUnit == 86400 ? _atMinutes : null,
                ),
              ],
            ],
            if (_isAgent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _instructions,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.supervisorSectionInstructions,
                  hintText: l10n.supervisorSectionInstructionsHint,
                  isDense: true,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              TextField(
                controller: _command,
                decoration: InputDecoration(
                  labelText: l10n.supervisorSectionCommand,
                  hintText: l10n.supervisorSectionCommandHint,
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _args,
                decoration: InputDecoration(
                  labelText: l10n.supervisorSectionArgs,
                  isDense: true,
                ),
              ),
            ],
            if (existing != null) ...[
              const SizedBox(height: 10),
              Text(
                l10n.supervisorSectionStats(
                  existing.present
                      ? l10n.supervisorSectionStateActive
                      : l10n.supervisorSectionStateIdle,
                  existing.restartCount ?? 0,
                  existing.lastRun ?? '—',
                ),
                style: context.textTheme.bodySmall?.copyWith(color: outline),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: _canSave ? () => unawaited(_submit()) : null,
                  child: Text(l10n.save),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const Spacer(),
                if (_editing)
                  TextButton(
                    onPressed: () => unawaited(_confirmDelete()),
                    child: Text(
                      l10n.delete,
                      style: TextStyle(color: context.theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
            Text(
              l10n.supervisorSectionAuthorHint,
              style: context.textTheme.bodySmall?.copyWith(color: outline),
            ),
          ],
        ),
      ),
    );
  }
}
