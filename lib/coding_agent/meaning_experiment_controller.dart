import 'dart:convert';

import 'package:flutter/foundation.dart';

typedef MeaningExperimentInvoke =
    Future<Map<String, Object?>> Function(
      String action,
      Map<String, Object?> arguments,
    );

/// Display state over the owner's installed operation. Serialized receipts are
/// observations: only the host's still-issued proposal can authorize an effect.
final class MeaningExperimentController extends ChangeNotifier {
  MeaningExperimentController({required this.invoke});

  final MeaningExperimentInvoke invoke;
  bool _disposed = false;
  bool _applyUnsettled = false;
  bool busy = false;
  Map<String, Object?>? preview;
  Map<String, Object?>? applied;
  Object? currentObservation;
  bool currentObservationUnknown = false;
  Map<String, Object?>? nativeStatus;
  final List<Map<String, Object?>> receipts = [];
  String? refusal;
  String? proposalId;
  String? runId;
  bool rollbackAvailable = false;
  bool proposalInvoked = false;

  Map<String, Object?> toJson() => {
    'busy': busy,
    'preview': preview,
    'applied': applied,
    'currentObservation': currentObservation,
    'currentObservationUnknown': currentObservationUnknown,
    'nativeStatus': nativeStatus,
    'receipts': List.of(receipts),
    'refusal': refusal,
    'proposalId': proposalId,
    'runId': runId,
    'rollbackAvailable': rollbackAvailable,
    'proposalInvoked': proposalInvoked,
    'authority': 'host_issued_only',
    'applyUnsettled': _applyUnsettled,
  };

  Future<Map<String, Object?>> action(String action) async {
    if (_disposed) return {'ok': false, 'error': 'meaning_session_unavailable'};
    if (busy) return {'ok': false, 'error': 'meaning_operation_busy'};
    busy = true;
    refusal = null;
    _changed();
    try {
      if (_applyUnsettled &&
          {'preview', 'rollback', 'finalize'}.contains(action)) {
        await _refreshNativeStatus();
        if (_disposed) {
          return {'ok': false, 'error': 'meaning_session_unavailable'};
        }
      }
      final Map<String, Object?> result;
      if (action == 'preview') {
        if (_applyUnsettled) {
          return _record({'ok': false, 'error': 'meaning_status_required'});
        }
        if (rollbackAvailable) {
          return _record({'ok': false, 'error': 'meaning_native_run_open'});
        }
        final ground = await invoke('ground', const {});
        if (ground['ok'] != true) return _record(ground);
        final request = ground['preview_request'];
        final groundingId = request is Map ? request['groundingId'] : null;
        if (request is! Map ||
            request['action'] != 'preview' ||
            groundingId is! String ||
            groundingId.isEmpty) {
          return _record({
            'ok': false,
            'error': 'meaning_preview_contract_unavailable',
          });
        }
        result = await invoke('preview', {
          'groundingId': groundingId,
          'opChain': [
            {'label': 'load_return'},
            {'label': 'literal', 'b': ' — updated'},
            {'label': 'concat'},
            {'label': 'return'},
          ],
        });
        if (result['ok'] == true) {
          preview = _copy(result);
          final proposal = result['proposal'] as Map?;
          proposalId =
              (proposal?['proposalId'] ?? result['proposalId']) as String?;
          runId = null;
          applied = null;
          _freshObservation(result['baseline_observation']);
          rollbackAvailable = false;
          proposalInvoked = false;
        }
      } else if (action == 'apply') {
        if (proposalInvoked) {
          return _record({'ok': false, 'error': 'proposal_already_invoked'});
        }
        if (proposalId == null) {
          return _record({'ok': false, 'error': 'meaning_preview_required'});
        }
        _applyUnsettled = true;
        proposalInvoked = true;
        _invalidateObservation();
        result = await invoke(action, {'proposalId': proposalId});
        if (result['runId'] is String) {
          runId = result['runId']! as String;
        }
        if (result['ok'] == true) {
          _applyUnsettled = false;
          applied = _copy(result);
          _freshObservation(result['observation']);
          runId = (result['runId'] ?? result['run_id']) as String?;
          rollbackAvailable = runId != null;
        }
      } else if (action == 'rollback' || action == 'finalize') {
        if (proposalId == null || runId == null) {
          return _record({'ok': false, 'error': 'meaning_run_required'});
        }
        if (_applyUnsettled) {
          return _record({'ok': false, 'error': 'meaning_status_required'});
        }
        if (!rollbackAvailable) {
          return _record({
            'ok': false,
            'error': 'meaning_recovery_unavailable',
          });
        }
        _applyUnsettled = true;
        rollbackAvailable = false;
        if (action == 'rollback') {
          _invalidateObservation();
        }
        result = await invoke(action, {
          'proposalId': proposalId,
          'runId': runId,
        });
        if (result['ok'] == true) {
          _applyUnsettled = false;
          rollbackAvailable = false;
          if (result.containsKey('observation')) {
            _freshObservation(result['observation']);
          }
        }
      } else if (action == 'status') {
        result = await invoke(action, const {});
        if (result['ok'] == true) {
          _readNativeStatus(result);
        }
      } else {
        return _record({'ok': false, 'error': 'meaning_action_unknown'});
      }
      return await _settleResult(
        result,
        reconcile: {'apply', 'rollback', 'finalize'}.contains(action),
      );
    } on Object catch (error) {
      return _settleResult({
        'ok': false,
        'action': action,
        'error': 'meaning_operation_unavailable',
        'detail': '$error',
      }, reconcile: {'apply', 'rollback', 'finalize'}.contains(action));
    } finally {
      busy = false;
      _changed();
    }
  }

  /// Reconcile once through the same owner after a refused or uncertain effect.
  /// This is observation only: no mutation is retried and no journal metadata
  /// can become a fresh runtime observation or a newly issued proposal.
  Future<Map<String, Object?>> _settleResult(
    Map<String, Object?> result, {
    required bool reconcile,
  }) async {
    final recorded = _record(result);
    if (reconcile && result['ok'] != true && !_disposed) {
      final originalRefusal = refusal;
      await _refreshNativeStatus();
      // Preserve the original effect's outcome rather than turning a successful
      // status read into a successful Apply/Undo receipt.
      refusal = originalRefusal;
    }
    return recorded;
  }

  Future<void> _refreshNativeStatus() async {
    try {
      final status = await invoke('status', const {});
      _record({...status, 'action': 'status'});
      if (status['ok'] == true) _readNativeStatus(status);
    } on Object catch (error) {
      _record({
        'ok': false,
        'action': 'status',
        'error': 'meaning_reconciliation_unavailable',
        'detail': '$error',
      });
    }
  }

  void _readNativeStatus(Map<String, Object?> result) {
    nativeStatus = _copy(result);
    _applyUnsettled = (result['native_runs'] as List? ?? const []).any((raw) {
      final native = raw as Map;
      return native['status'] == 'open' ||
          native['known_in_session'] != true && native['status'] == 'applied';
    });
    final previews = result['issued_previews'] as List? ?? const [];
    final issued = previews.any(
      (raw) => ((raw as Map)['proposal'] as Map?)?['proposalId'] == proposalId,
    );
    for (final raw in previews) {
      final issuedPreview = raw as Map;
      if ((issuedPreview['proposal'] as Map?)?['proposalId'] == proposalId) {
        proposalInvoked = issuedPreview['invoked'] == true;
      }
    }
    if (proposalId != null && !issued) {
      proposalId = null;
      runId = null;
      rollbackAvailable = false;
      refusal = 'meaning_preview_lost';
    }
    if (runId != null) {
      final runs = result['native_runs'] as List? ?? const [];
      rollbackAvailable = runs.any((raw) {
        final run = raw as Map;
        return run['runId'] == runId &&
            run['proposalId'] == proposalId &&
            run['known_in_session'] == true &&
            run['status'] == 'applied';
      });
    } else if (proposalId != null && issued) {
      final nativeReceipts = result['receipts'] as List? ?? const [];
      final runs = result['native_runs'] as List? ?? const [];
      for (final raw in nativeReceipts.reversed) {
        final receipt = raw as Map;
        if (receipt['action'] == 'apply' &&
            receipt['proposalId'] == proposalId &&
            runs.any((rawRun) {
              final native = rawRun as Map;
              return native['runId'] == receipt['runId'] &&
                  native['proposalId'] == proposalId &&
                  native['known_in_session'] == true &&
                  native['status'] == 'applied';
            })) {
          runId = receipt['runId'] as String?;
          rollbackAvailable = runId != null;
          break;
        }
      }
    }
  }

  void _invalidateObservation() {
    currentObservation = null;
    currentObservationUnknown = true;
    _changed();
  }

  void _freshObservation(Object? observation) {
    currentObservation = observation;
    currentObservationUnknown = observation == null;
  }

  Map<String, Object?> _record(Map<String, Object?> result) {
    final observed = _copy(result);
    receipts.add(observed);
    if (observed['ok'] != true) {
      final error =
          observed['error'] ??
          observed['bounce'] ??
          (observed['outcome'] as Map?)?['detail'] ??
          'meaning_operation_refused';
      refusal = '$error';
    }
    return observed;
  }

  static Map<String, Object?> _copy(Map<String, Object?> value) =>
      Map<String, Object?>.from(jsonDecode(jsonEncode(value)) as Map);

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
